//! 《形式化入门》一文的配套代码：TAPL 第 3、8 章的布尔 + 自然数语言。
//!
//! - `Term`：项（结构归纳的对象）
//! - `step`：一步归约 t ⟶ t'（E-* 规则）
//! - `type_of`：类型检查算法（相对 T-* 规则可靠且完备）

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Term {
    True,
    False,
    If(Box<Term>, Box<Term>, Box<Term>),
    Zero,
    Succ(Box<Term>),
    Pred(Box<Term>),
    IsZero(Box<Term>),
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Type {
    Bool,
    Nat,
}

/// 数值 nv ::= 0 | succ nv
pub fn is_nv(t: &Term) -> bool {
    match t {
        Term::Zero => true,
        Term::Succ(t) => is_nv(t),
        _ => false,
    }
}

/// 值 v ::= true | false | nv
pub fn is_value(t: &Term) -> bool {
    matches!(t, Term::True | Term::False) || is_nv(t)
}

/// t ⟶ t'。None 表示不存在 t'：t 是值，或者受阻了。
pub fn step(t: &Term) -> Option<Term> {
    use Term::*;
    match t {
        If(c, a, b) => match &**c {
            True => Some((**a).clone()),                             // E-IfTrue
            False => Some((**b).clone()),                            // E-IfFalse
            c => Some(If(Box::new(step(c)?), a.clone(), b.clone())), // E-If
        },
        Succ(t1) => Some(Succ(Box::new(step(t1)?))), // E-Succ
        Pred(t1) => match &**t1 {
            Zero => Some(Zero),                         // E-PredZero
            Succ(n) if is_nv(n) => Some((**n).clone()), // E-PredSucc
            t1 => Some(Pred(Box::new(step(t1)?))),      // E-Pred
        },
        IsZero(t1) => match &**t1 {
            Zero => Some(True),                      // E-IsZeroZero
            Succ(n) if is_nv(n) => Some(False),      // E-IsZeroSucc
            t1 => Some(IsZero(Box::new(step(t1)?))), // E-IsZero
        },
        True | False | Zero => None, // 引理「值不可归约」
    }
}

/// 类型检查算法。「算法可靠性」+「算法完备性」：type_of(t) = Some(T) 当且仅当 t : T。
pub fn type_of(t: &Term) -> Option<Type> {
    use Term::*;
    match t {
        True | False => Some(Type::Bool), // T-True / T-False
        Zero => Some(Type::Nat),          // T-Zero
        Succ(t1) | Pred(t1) => {
            // T-Succ / T-Pred
            (type_of(t1)? == Type::Nat).then_some(Type::Nat)
        }
        IsZero(t1) => {
            // T-IsZero
            (type_of(t1)? == Type::Nat).then_some(Type::Bool)
        }
        If(c, a, b) => {
            // T-If
            let ta = type_of(a)?;
            (type_of(c)? == Type::Bool && type_of(b)? == ta).then_some(ta)
        }
    }
}

pub fn size(t: &Term) -> usize {
    use Term::*;
    match t {
        True | False | Zero => 1,
        Succ(t1) | Pred(t1) | IsZero(t1) => size(t1) + 1,
        If(a, b, c) => size(a) + size(b) + size(c) + 1,
    }
}

pub fn depth(t: &Term) -> usize {
    use Term::*;
    match t {
        True | False | Zero => 0,
        Succ(t1) | Pred(t1) | IsZero(t1) => depth(t1) + 1,
        If(a, b, c) => depth(a).max(depth(b)).max(depth(c)) + 1,
    }
}

/// 深度 ≤ d 的全部项（TAPL 3.2.3 的 S_i 的逐层构造）。
pub fn all_terms(d: usize) -> Vec<Term> {
    use Term::*;
    let mut s = vec![True, False, Zero];
    for _ in 0..d {
        let prev = s.clone();
        let mut next = vec![True, False, Zero];
        for t in &prev {
            next.push(Succ(Box::new(t.clone())));
            next.push(Pred(Box::new(t.clone())));
            next.push(IsZero(Box::new(t.clone())));
        }
        for a in &prev {
            for b in &prev {
                for c in &prev {
                    next.push(If(Box::new(a.clone()), Box::new(b.clone()), Box::new(c.clone())));
                }
            }
        }
        s = next;
    }
    s
}
