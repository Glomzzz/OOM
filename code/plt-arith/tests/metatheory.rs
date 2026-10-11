//! 文中定理的可执行版本。

use plt_arith::Term::*;
use plt_arith::*;

/// 用给定的 step / type_of 检查进展 + 保型；返回第一个反例。
fn check_safety(
    terms: &[Term],
    step: impl Fn(&Term) -> Option<Term>,
    type_of: impl Fn(&Term) -> Option<Type>,
) -> Result<usize, String> {
    let mut typed = 0;
    for t in terms {
        let Some(ty) = type_of(t) else { continue };
        typed += 1;
        let mut cur = t.clone();
        // 每步都让项变小，所以 size(t) 步内一定停下
        for _ in 0..=size(t) {
            let Some(next) = step(&cur) else {
                if !is_value(&cur) {
                    return Err(format!("进展失败：{t:?} 归约到受阻的 {cur:?}"));
                }
                break;
            };
            if type_of(&next) != Some(ty) {
                return Err(format!("保型失败：{cur:?} ⟶ {next:?}"));
            }
            cur = next;
        }
        if !is_value(&cur) {
            return Err(format!("没有在 size 步内停下：{t:?}"));
        }
    }
    Ok(typed)
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

/// 定理「进展」+「保型」：进展与保型
#[test]
fn safety() {
    let typed = check_safety(&corpus(), step, type_of).unwrap();
    assert!(typed > 5_000, "良类型样本太少：{typed}");
}

/// 定理「类型唯一」。type_of 是函数，这里检查值的类型与形状一致（典范形式）。
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

/// T-If 不检查 else 分支：保型被破坏，safety 必须报错。
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
