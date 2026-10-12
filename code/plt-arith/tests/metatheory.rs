//! 文中定理的可执行版本。

use plt_arith::Term::*;
use plt_arith::*;

#[derive(Debug, Default)]
struct SafetyStats {
    typed: usize,
    steps: usize,
}

/// 用给定的 step / type_of 检查进展、保型和大小下降；返回第一个反例。
fn check_safety(
    terms: &[Term],
    step: impl Fn(&Term) -> Option<Term>,
    type_of: impl Fn(&Term) -> Option<Type>,
) -> Result<SafetyStats, String> {
    let mut stats = SafetyStats::default();
    for t in terms {
        let Some(ty) = type_of(t) else { continue };
        stats.typed += 1;
        let mut cur = t.clone();
        let mut cur_size = size(&cur);
        let mut stopped = false;
        // 正确实现至多归约 size(t) - 1 步，再调用一次得到 None。
        // 保留独立步数上限，但不预先假定待测实现遵守下降性质。
        for _ in 0..cur_size {
            let Some(next) = step(&cur) else {
                if !is_value(&cur) {
                    return Err(format!("进展失败：{t:?} 归约到受阻的 {cur:?}"));
                }
                stopped = true;
                break;
            };
            let next_size = size(&next);
            if next_size >= cur_size {
                return Err(format!("大小未严格下降：{cur:?} ⟶ {next:?}"));
            }
            if type_of(&next) != Some(ty) {
                return Err(format!("保型失败：{cur:?} ⟶ {next:?}"));
            }
            stats.steps += 1;
            cur = next;
            cur_size = next_size;
        }
        if !stopped {
            return Err(format!("没有在 size(t) 次调用内返回 None：{t:?}"));
        }
    }
    Ok(stats)
}

/// xorshift64*：确定性随机项，覆盖深度 2 以上的情形。
fn random_term(seed: &mut u64, d: usize) -> Term {
    *seed ^= *seed >> 12;
    *seed ^= *seed << 25;
    *seed ^= *seed >> 27;
    let r = seed.wrapping_mul(0x2545_F491_4F6C_DD1D) >> 33;
    if d == 0 {
        return [True, False, Zero][(r % 3) as usize].clone();
    }
    let b = |s: &mut u64| Box::new(random_term(s, d - 1));
    match r % 8 {
        0 => True,
        1 => False,
        2 => Zero,
        3 => Succ(b(seed)),
        4 => Pred(b(seed)),
        5 => IsZero(b(seed)),
        _ => If(b(seed), b(seed), b(seed)),
    }
}

fn corpus() -> Vec<Term> {
    let mut ts = all_terms(2); // 深度 ≤ 2 穷举，59439 个
    let mut seed = 0x9E37_79B9_7F4A_7C15u64;
    for _ in 0..50_000 {
        ts.push(random_term(&mut seed, 6));
    }
    ts
}

#[test]
fn enumeration_size() {
    assert_eq!(all_terms(0).len(), 3);
    assert_eq!(all_terms(1).len(), 39);
    assert_eq!(all_terms(2).len(), 59_439);
    assert!(all_terms(2).iter().all(|t| depth(t) <= 2));
}

/// 引理「深度小于大小」：depth(t) < size(t)
#[test]
fn depth_lt_size() {
    for t in corpus() {
        assert!(depth(&t) < size(&t), "{t:?}");
    }
}

/// 引理「值不可归约」
#[test]
fn values_do_not_step() {
    for t in corpus().iter().filter(|t| is_value(t)) {
        assert_eq!(step(t), None, "{t:?}");
    }
}

/// 引理「归约使大小严格下降」：不局限于良类型项。
#[test]
fn reduction_decreases_size() {
    for t in corpus() {
        if let Some(next) = step(&t) {
            assert!(size(&next) < size(&t), "{t:?} ⟶ {next:?}");
        }
    }
}

/// 进展、保型与终止性：接受的项必须实际停止在同类型值上。
#[test]
fn safety() {
    let stats = check_safety(&corpus(), step, type_of).unwrap();
    assert!(stats.typed > 5_000, "良类型样本太少：{stats:?}");
    assert!(stats.steps > 0, "没有实际归约任何项：{stats:?}");
}

#[test]
fn safety_rejects_self_looping_value() {
    let err = check_safety(&[True], |t| Some(t.clone()), type_of).unwrap_err();
    assert!(err.starts_with("大小未严格下降："), "{err}");
}

#[test]
fn safety_rejects_self_looping_non_value() {
    let t = Pred(Box::new(Zero));
    let err = check_safety(&[t], |t| Some(t.clone()), type_of).unwrap_err();
    assert!(err.starts_with("大小未严格下降："), "{err}");
}

#[test]
fn safety_rejects_self_loop_after_computation() {
    let t = Pred(Box::new(Zero));
    let err = check_safety(
        &[t],
        |t| if matches!(t, Zero) { Some(Zero) } else { step(t) },
        type_of,
    ).unwrap_err();
    assert!(err.starts_with("大小未严格下降："), "{err}");
}

#[test]
fn safety_observes_normal_stops() {
    let stats = check_safety(&[True, Zero, Pred(Box::new(Zero))], step, type_of).unwrap();
    assert_eq!(stats.typed, 3);
    assert_eq!(stats.steps, 1);
}

/// 典范形式：检查值的类型与形状一致，不把函数单返回值当作类型唯一性的证明。
#[test]
fn canonical_forms() {
    for t in corpus().iter().filter(|t| is_value(t)) {
        match type_of(t) {
            Some(Type::Bool) => assert!(matches!(t, True | False)),
            Some(Type::Nat) => assert!(is_nv(t)),
            None => panic!("值必有类型：{t:?}"),
        }
    }
}

#[test]
fn examples() {
    let s = |t| Box::new(t);
    // 文中推导树的例子
    let t = Pred(s(If(s(IsZero(s(Zero))), s(Succ(s(Zero))), s(Zero))));
    assert_eq!(step(&t), Some(Pred(s(If(s(True), s(Succ(s(Zero))), s(Zero))))));
    // 受阻的项
    assert_eq!(step(&Succ(s(True))), None);
    assert_eq!(type_of(&Succ(s(True))), None);
    // 保守性：运行没问题，但没有类型
    let t = If(s(True), s(Zero), s(False));
    assert_eq!(step(&t), Some(Zero));
    assert_eq!(type_of(&t), None);
}

// ---------- 规则作为关系：列出所有 t' 使 t ⟶ t' ----------

/// 逐条照抄 E-* 规则，不做任何排序或排除。`loose_pred` 为真时，
/// E-PredSucc 写成文中的错误版本 pred (succ t) ⟶ t。
fn steps_rel(t: &Term, loose_pred: bool) -> Vec<Term> {
    let b = |t: Term| Box::new(t);
    let mut out = Vec::new();
    match t {
        If(c, x, y) => {
            if **c == True { out.push((**x).clone()); }                     // E-IfTrue
            if **c == False { out.push((**y).clone()); }                    // E-IfFalse
            for c2 in steps_rel(c, loose_pred) { out.push(If(b(c2), x.clone(), y.clone())); } // E-If
        }
        Succ(t1) => for t2 in steps_rel(t1, loose_pred) { out.push(Succ(b(t2))); }       // E-Succ
        Pred(t1) => {
            if **t1 == Zero { out.push(Zero); }                             // E-PredZero
            if let Succ(n) = &**t1 {
                if loose_pred || is_nv(n) { out.push((**n).clone()); }      // E-PredSucc
            }
            for t2 in steps_rel(t1, loose_pred) { out.push(Pred(b(t2))); }  // E-Pred
        }
        IsZero(t1) => {
            if **t1 == Zero { out.push(True); }                             // E-IsZeroZero
            if let Succ(n) = &**t1 { if is_nv(n) { out.push(False); } }     // E-IsZeroSucc
            for t2 in steps_rel(t1, loose_pred) { out.push(IsZero(b(t2))); } // E-IsZero
        }
        True | False | Zero => {}
    }
    out
}

/// 定理「确定性」，并且 step 恰好是这个关系的函数版本。
#[test]
fn determinism() {
    for t in corpus() {
        let all = steps_rel(&t, false);
        assert!(all.len() <= 1, "{t:?} 有多种归约方式：{all:?}");
        assert_eq!(step(&t), all.into_iter().next(), "{t:?}");
    }
}

/// 错误的 E-PredSucc：类型安全仍然成立，但确定性被破坏。
#[test]
fn loose_pred_breaks_determinism() {
    let t = Pred(Box::new(Succ(Box::new(Pred(Box::new(Zero))))));
    let all = steps_rel(&t, true);
    assert_eq!(all.len(), 2, "{all:?}"); // pred 0 与 pred (succ 0)
    assert!(corpus().iter().any(|t| steps_rel(t, true).len() > 1));
}

/// 错误检查器忽略 else 分支，违反相对原类型规则的可靠性；安全测试会发现这个错误。
fn type_of_bad_if(t: &Term) -> Option<Type> {
    match t {
        If(c, a, _) => (type_of_bad_if(c)? == Type::Bool).then(|| type_of_bad_if(a)).flatten(),
        Succ(t1) | Pred(t1) => (type_of_bad_if(t1)? == Type::Nat).then_some(Type::Nat),
        IsZero(t1) => (type_of_bad_if(t1)? == Type::Nat).then_some(Type::Bool),
        _ => type_of(t),
    }
}

#[test]
fn bad_if_breaks_safety() {
    let err = check_safety(&corpus(), step, type_of_bad_if).unwrap_err();
    println!("{err}");
}
