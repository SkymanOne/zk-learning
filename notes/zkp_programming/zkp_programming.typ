#import "../base.typ": *
#show: note

= Programming ZKPs

Here is the general overview to get from an idea to ZKP.

#align(center,
  diagram(
    spacing: 5em,
    node-stroke: 0.5pt,
    node((0, 0), [*Concept*]),
    edge("->", [Coding]),
    node((1, 0), [*Program*],),
    edge("->", [Compiler]),
    node((2, 0), [*R1CS \ Arithemtic circuit*]),
    edge("->", [Setup]),
    node((3, 0), [*Params*]),
    edge("->", [Prove]),
    node((4, 0), [*ZKP*]),
  )
)

= Arithemtic Circuits

Arithmetic circuit is concrete instance of a predicate $phi$ that the prove tries to prove over inputs $x, w$.

Arithemtic circuits perform over a prime field where

- $p$ a large prime
- $ZZ_p$ integers that $mod p$ - prime field
- Operations that are performed on the field are: $+, times, eq (mod 5)$
-  e.g. $ZZ_5$
  - $4 + 5 = 9 mod 5 = 4$
  - $4 times 4 = 16 mod 5 = 1$

One way of viewing the Arithemtic Circuits is as systems of field equations over a prime field:
- $w_0 times w_0 times w_0 eq x$
- $w_1 times w_1 eq x$

= Rank 1 Contraint Systems (R1CS)
The most common for ZKP ACs

*Representation:*
- _x_: field elements $x_1, ..., x_l$
- _w_: field elements $w_1, ..., w_(m-l-1)$
- $phi$: _n_ contraints (equations) of form
  - $alpha times beta eq gamma$
  - where $alpha, beta, gamma$ are *affine* (linear with an optional constant added) combinations of variables

Examples:
- $w_2 times (w_3 - w_2 - 1) = x_1$

  - $alpha = w_2 \ beta = (w_3 - w_2 - 1) ("it's affine") \ gamma = x_1$

- $w_2 times w_2 = w_2$

- $cancel(w_2 times w_2 times w_2 = x_1)$ We have three variables multiplied so this is not an equation of the acceptable format. Instead, we can transform it into 2 equations by introducing another variable:
  - $w_2 times w_2 = w_4$
  - $w_4 times w_2 = x_1$


We can also represent R1CS in the matrix form where:
- _x_: vector of $ell$ field element
- _w_: vector of $m - ell - 1$ field elements
- $phi$: matrices $A, B, C in ZZ^(n times m)_p$ s.t.
  - $z = (1 || x || w) in  ZZ^(n times m)_p$, $||$ - means concatenation
  - which hold when $A z circle.tiny B z = C z$, $circle.tiny$ - element-wise product.

An example of element wise product:
$
A circle.tiny B = 
mat(
  a, b;
  c, d;
  )
  circle.tiny
mat(
  e, f;
  g, h;
  )
=
mat(
  a times e, b times f;
  c times g, d times h;
)
$

When taking an inner product of $A z$, every row of _A_ define an affine combination of variables _x_ and _w_. So, every row in _A_, _B_ and _C_ define a single rank 1 contraint.

== Example of writing an AC as R1CS

Given the following circuit.

#align(center,
  diagram(
    spacing: 2em,
    node-stroke: 0.5pt,
    node((0, 0), [$w_0$], name: <w0>, stroke: 0pt),
    node((0, 2), [$w_1$], name: <w1>, stroke: 0pt),
    node((0, 3), [$x_0$], name: <x0>, stroke: 0pt),
    node((1, 1), [$times$], name: <mul1>, shape: circle),
    node((2, 2), [$+$], name: <add>, shape: circle),
    node((3, 3), [$eq$], name: <eq>, shape: circle),
    node((1, 4), [$times$], name: <mul2>, shape: circle),

    edge(<w0>, <mul1>, "->"),
    edge(<w1>, <mul1>, "->"),
    edge(<w1>, <mul2>, "->"),
    edge(<x0>, <add>, "->"),
    edge(<x0>, <mul2>, "->"),
    edge(<mul1>, <add>, "->", [$w_2$]),
    edge(<mul2>, <eq>, "->", [$w_4$]),
    edge(<add>, <eq>, "->", [$w_3$]),
  )
)

We can transform it to R1CS using the following procedure:
1. Introduce intermediate witness (_w_) variables
2. Rewrite equations
  - $w_0 times w_1 = w_2$
  - $w_3 = w_2 + x_0$ ($beta$ is _1_, therefore omitted)
  - $w_1 times x_0 = w_4$
  - $w_3 = w_4$

= HDLs for R1CS

As an HDL (hardware description language) we are going to use Circom.

*In HDL objects are:*
- Wires
- Gates
- Circuits/Subcircuits

#pagebreak()

*Actions are:*
- Connect Wires
- Create sub-circuits
- cannot call functions or mutate variables

Circom is an HDL for R1CS:
- Wires: R1CS vars
- Gates: R1CS contraints

It sets values to vars and creates R1CS contraints.

=== Circom

Let's looks at the basic example:

```circom
template Multiply() {
  signal input x; // signal is a wire
  signal input y;
  signal output z;

  z <-- x * y // set signal value
  z === x * y // creates a contraint, must rank-1
  // OR z <== x * y
}

component main {public [x]} = Multiply();
```

`===` creates a contraint, must rank-1, one side must be linear, the other side must be quadratic

- `template` is a subcircuit.
- `public [x]` describes that `x` is public input in the instance of the template.

=== Circom Metaprogramming

Circom has following metaprogramming features:
- template args
- Signal arrays
- Vars
  - Mutable
  - Not signals
  - Evaluated at compile-time
- Loops
- If statements
- Array access

```circom
template RepeatedSquaring(n) {
  signal input x;
  singal output y;

  signal xs[n+1];
  xs[0] <== x;

  for (var i = 0; i < n; i++) {
    xs[i+1] <== xs[i] * xs[i];
  }
  y <== xs[n]
}
component main {public [x]} = RepeatedSquaring(1000);
```

=== Circom witness Computation and Sub-circuits

Witness computation is more general than R1CS
  - `<--` is more general than `===`, you can put any value since it justs sets the value, it doesn't create a constraint.

```circom
template NonZero() {
  signal input in;
  signal inverse;
  inveser <-- 1 / in; // not R1CS
  1 === in * signal' // is R1CS, creates constraint
}
```

`component`s hold sub-circuits
  - Accesses input/outputs with dot notation

```circom
template Main() {
  signal input a; signal input b;
  component nz = NonZero();
  nz.in <== a;
  0 === a * b;
}
```