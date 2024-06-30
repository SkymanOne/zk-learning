#import "../base.typ": *
#show: note

= Overview of Modern SNARK Constructions 

From this time we focus on the non-interactive proofs.

#def([
  *SNARK*: a succint proof that a certain statement is true.
])

Example statement: "I know an `m` s.t. `SHA256(m) = 0`"

The proof is *short* and *fast* to verify.

*zk-SNARK*: the proof  reveals nothing about `m`.

The power ZKPs:

#quote([_A single reliable machine (e.g. Blockchain) can monitor and verify the computations of a set of powerful machines working with unreliable software._])

= SNARK Components

== Arithemtic circuits

We denote finite field $FF = {0, ..., p - 1}$ as a finite field for some prime $p > 2$.

#def([
  *Arithemtic circuit*: $C: FF^n -> FF$ - it takes $n$ elements in $FF$ and produces one element in $FF$. 
  It can be reason as:
  - Directed asyclic graph where internal nodes are labeles as maths operations and inputs are labeleld as constants and variables.
  - It defines an n-variate polynomial with an evaluation recipe
])

#align(center, image("arithmetic_circuit.png", width: 40%))

The above circuit can be represented as a n-variate polynomial $5x_0 + 3(x_1 + x_2) $

We denote $|C| = $ number of gates in a circuit $C$

We have two different circuit types:
- *Unstructured*: a circuit with arbitraty wires
- *Structured*: a circuit is built in layers of the same circuit layer that is repeated 

#align(center,
  diagram(
    spacing: 2em,
    node-stroke: 0.5pt,
    node((0, 0), [*Input*], shape: circle, width: 5em),
    edge("->"),
    node((1, 0), [*M*],),
    edge("->"),
    node((2, 0), [*M*]),
    edge("->"),
    node((3, 0), [*...*], stroke: 0pt),
    edge("->"),
    node((4, 0), [*M*]),
    edge("->"),
    node((5, 0), [*Output*], shape: circle, width: 5em),
    node(enclose: ((1, 0), (4, 0)))
  )
)

$M$ is often called a virtual machine (VM), you can think about it as one step of computation.

== NARK: Non-Interactive ARgumebt of Knowledge

Given some arithemtic circuit: $C(x, w) -> FF$ where 
- $x in FF^n$ - a pubic statement 
-  $w in FF^M$ - a secret wintess

Before executing the circuit there is a preprocessing setup: $S(C) ->$ public params (*_pp_*, *_pv_*)

It takes a circuit description and produces public params.


#align(center,
  diagram(
    spacing: 2em,
    node-stroke: 0.5pt,
    node((0, 0), [*pp, x, w*], stroke: 0pt),
    edge("->"),
    node((0, 1), [Prover], height: 3em),
    edge("->", [proof $pi$ that $C(x, w) = 0$]),
    node((7, 1), [Verifier], height: 3em),
    edge("<-"),
    node((7, 0), [*vp, x*], stroke: 0pt),
    edge((7, 1), (8, 1), "->"),
    node((8, 1), [Accept/Reject], stroke: 0pt),
  )
)

#def([
  A *preprocessing NARK* is a triple $(S, P, V)$:

  - $S(C) -> $ public params _(pp, vp)_ for prover and verifier

  - $P("pp", x, w) -> "proof" pi$
  
  - $V("vp", x, pi) -> "accept/reject"$
])

Side note: _All algorithms and adversary have access to a random oracle_

#def([
  *Random oracle*: is an oracle (black box) that responds to any unique queary with a uniformly distributed random response from its output domain.
  If the input is repeated, the same output is returned.
])

== SNARK: Succinct Non-Interactive ARgumebt of Knowledge

We now impose additional requirements on the NARK

- *Completeness:* $forall x,w space C(x, w) = 0 => P[V("vp", x, P("pp", x, w)) = "accept"] = 1$

- *Knowledge soundness*: _V_ accepts $=> P "knows" w "s.t." C(x, w) = 0$. \ An extractor _E_ can extract a valid _w_ from _P_.

- (Optional) *Zero-Knowledge*: $(C, "pp", "vp", x pi)$ reveal nothing new about _w_.


#def([
  A #underline([*succint*]) *preprocessing NARK* is a triple $(S, P, V)$:

  - $S(C) -> $ public params _(pp, vp)_ for prover and verifier

  - $P("pp", x, w) -> "short proof" pi$; $"len"(pi) = "sublinear"(|w|)$
  
  - $V("vp", x, pi) -> "accept/reject"$; *fast to verify*: $"time"(V) = O_(lambda)(|x|, "sublinear"(|C|))$
])

In practice we have a stronger constraints:

#def([
  A #underline([*strongly succint*]) *preprocessing NARK* is a triple $(S, P, V)$:

  - $S(C) -> $ public params _(pp, vp)_ for prover and verifier

  - $P("pp", x, w) -> "short proof" pi$; $"len"(pi) = log(|w|)$
  
  - $V("vp", x, pi) -> "accept/reject"$; *fast to verify*: $"time"(V) = O_(lambda)(|x|, log(|C|))$
])

We have a _Big O_ notation with $lambda$ symbol, $lambda$ usually refers to some secret parameter that represents the level of security (e.g. length of keys, etc.). Therefore, the complexity is analyzed with repsect to the secret parameter.

You can notice that because the verifier need to verify the proof in shorter time than the circuit size, 
it does not have the time to read the circuit. This is the reason why we have the preprocessing step _S_. It reads the circuit _C_ and generates a _summary_ of it. Therefore, $|"vp"| ≤ log(|C|)$

== Types of preprocessing Setup

Suppose we have a setup for some circuit _C_: $S(C; r) -> $ _public params (pp, vp)_, where _r_ - random bits.

We have the following types of setup:

- *Trusted setup per circuit*: $S(C; r)$, _r_ random bits must be kept private from the prover, otherwise it can prove false statements.

- *Trsuted universal (updatable) setup:* secret _r_ is independent of _C_ \ $S = (S_("init"), S_("index")): S_("init")(lambda;r) -> "gp",  S_("index")("gp";C) -> "(pp, vp)"$ where
  - $S_"init"$ - one time setup
  - $S_"index"$ - deterministic algorith
  - _gp_ - global params \
The benefit of the universal setup that we can generate params for as many circuits as we want.

- *Transperent setup:* no secret data, $S(C)$


#pagebreak()
= Overview of Proving Systems

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 10pt,
  align: center,
  table.header(
    [], [*Size of proof*], [*Verifier time*], [*Setup*], [*Post-\ Quantum*]
  ),
  [*Groth'16*], [\~ 200 bytes \ $O_(lambda(1))$], [\~ 1.5 ms \ $O_(lambda(1))$], [trusted setup per circuit], [no],

  [*Plonk & \ Marlin*], [\~ 400 bytes \ $O_(lambda(1))$], [\~ 3 ms \ $O_(lambda(1))$], [universal trusted setup], [no],

  [*Bulletproofs*], [\~ 1.5 KB \ $O_(lambda(log|C|))$], [\~ 3 sec \ $O_(lambda(|C|))$], [transperent], [no],

  [*Bulletproofs*], [\~ 100 KB \ $O_(lambda(log^2|C|))$], [\~ 3 sec \ $O_(lambda(log^2|C|))$], [transperent], [yes],
)

= Knowledge Soundness

If _V_ accepts then _P_ knows _w_ s.t. $C(x, w) = 0$.

It means than we can _w_ from _P_.

#def([
  $(S, P, V)$ is (adaptively) *knowledge sound* for a circuit _C_ if for every polynomial time adversary $A = (A_0, A_1)$ s.t. 

  _gp_ $<- S_("init")()$, $(C, x, "st") <- A_0("gp")$, _(pp, vp)_ $<- S_("index")(C)$, $pi <- A_1("pp", x, "st")$ : 

  $P[V("vp", x, pi) = "accept"] > 1 "/" 10^6$ (non-negligible).
])

_A_ acts as a malicious prover that tries to prove a statement without a knowledge of _w_. It is split into two algorithms $A_0$ and $A_1$

Given global parameters to $A_0$, the malicous prover generates a circuit, and a statement for which it tries to forge a proof for, the malicous prover also generates some internal state _st_.

Then, public params are generates from the circuit. Then malicious $A_1$ generates a forged proof $pi$ from prover params, a statements and an internal state.

If a malicious prover convinces a verifier with a probability grater than $1 "/" 10^6$, then there is an efficient *extractor* _E_ (that uses _A_) s.t. 

#def([
  _gp_ $<- S_("init")()$, $(C, x, "st") <- A_0("gp")$, $w <- E("gp", C, x)$ (using $A_1$): 

  $P(C(x, w) = 0) > 1 "/" 10^6 - epsilon$ (for a negligible $epsilon$)
])

= Building Efficent SNARKs

There are a general paradigm: two steps
- A functional commitment scheme. Requires Cryptographic assumptions

- A compatible interactive oracle proof. Does not require any assumptions


#align(center,
  diagram(
    spacing: 1em,
    node-stroke: 0.5pt,
    node((0, 0), [Functional \ commitment \ scheme], stroke: 0pt, name: <one>),
    node((0, 3), [IOP], stroke: 0pt, name: <two>),
    node((1, 2), [Proving process], stroke: 0pt, name: <prove>),
    node((2, 2), [SNARK for \ general circuits], stroke: 0pt, name: <snark>),
    edge(<one>, <prove>, "->"),
    edge(<two>, <prove>, "->"),
    edge(<prove>, <snark>, "->"),
  )
)

== Functional Commitments

There are two algorithms:

- `commit(m, r) -> com` (_r_ is chosen at random)

- `verify(m, com, r) -> accept/reject`

There are two informal properties:

- *binding*: cannnot produce `com` and two valid commitment opennings for `com`

- *hiding*: `com` reveals nothing about commited data

Here we gave a standard hash construction:

Given some fixed hash function: $H: M times R -> T$, we the two algorithms become:

- `commit(m, r): com := H(m, r)`

- `verify(m, com, r): accept if com = H(m, r)`

Then we can construct a functional commitment scheme.

=== Describing commitment to a function
Given some family of functions: $F = {f: X -> Y}$

The commiter acts as a prover. The prover chooeses some randonmness _r_ and commits a descirption of a function $f$ with _r_ to a verifier. The function can decribed as a circuit, or as a binary code, etc. The verifier then sends $x in X$, and the prover will respond with $y in Y$ alognside a proof $pi$, such that $f(x) = y$ and $f in F$.

#pagebreak()

We can describe a commitment to a function family $F$ using the following procedure (syntax):

- $"setup"(1^lambda) -> "gp"$ - outputs global public parameteres _gp_.

- $"commit"("gp", f, r) -> "com"_f$ - produces a commitment to $f in F$ with $r in R$. It involves a *binding* (and optionall *hiding*, for ZK) committment scheme for $F$.

- eval(Prover P, verifier V) - an evaluation protocol between a prover and a verifier where for a given $"com"_f$ and $x in X, y in Y$:

 - $P("gp", f, x, y, r) ->$ short proof $pi$

 - $V("gp", "com"_f, x, y, pi) ->$ accept/reject.

This evaluation protocol is a SNARK itself for the *relation*: \ $f(x) = y, f in F, "commit"("gp", f, r) = "com"_f$

For the setup, the public statements are $"com"_f, x, y$ that are known to verifier. The prover is proving that it knows the description of $f$ (a witness), and $r$ s.t. the *relation* is true.

== Commitment schemes

- *Polynomial*: a commit to a #underline("univariate") $f(X) in FF^(≤d)_(p)[X]$. The family of functions is the set of all univarate polynomial function with degree of at most _d_

- *Multilinear*: a commit to a #underline("multilienar") $f in FF^(≤1)_(p)[X_1, ..., X_k]$. We a commiting to polynomial with multiple variables $X_1, ..., X_k$ but in each polynomial the degree is at most 1. e.g. $f(x_1, ..., x_k) = x_1x_2 + x_1x_4x_5 + x_7$

- *Vector (e.g. Merke trees)*: a commit to $accent(u, arrow) = (u_1, ..., u_d) in F^d_p$. In the future, we would like to "open" any particular cell in the vector s.t. $f_(accent(u, arrow))(i) = u_i$. We can reason as we are commit to a function that is identified by a vector. Therefore, we would like to prove that given index _i_ it evaluated to a cell $u_i$. Merkle trees are used for implementation of a vector commitmement.

- *Inner product* (aka inner product arguments - IPA): a commit to $accent(u, arrow) in F^d_p$. It commits to a function $f_(accent(u, arrow))(accent(v, arrow)) = (accent(u, arrow), accent(v, arrow))$ (inner product of _u_ and _v_). We later prove that given some vector _v_ for a function identified by a vector _u_, it results in an expected inner product value.

== Polynomial Commitments

Suppose a prover commits to a polynomial  $f(X) in FF^(≤d)_(p)[X]$.

Then the evaluation scheme *eval* looks as following:

For public $u, v in FF_p$ (in finite field), prover can convince the verifier that the committed polynomial satisfies
#block(stroke: 1pt, inset: 8pt, [
  $f(u) = v$ and $"deg"(f) ≤ d$
])

Note that the verifier knows $(d, "com"_f, u, v)$. To make this proof a SNARK, the proof size and the verifier time should be $O_(lambda)(log d)$


Also note that trivial commitmement schemes are not a polynomial commitment. An example of a trivial commitment is as follows:

- _commit_$(f = sum^d_(i=0)a_i X^i, r)$: outputs $"com"_f <- H((a_0, ..., a_d), r)$. We simply output a commitment to all coefficients of a polynomial (just a hash of them).

- _eval_: prover sends $pi = ((a_0, ..., a_d), r)$ to verifier; and verifier accepts if $f(u) = v$ and $ H((a_0, ..., a_d), r) = "com"_f$

*The problem* with this commitment scheme is that the proof $pi$ is not succinct. Specifically, the proof size and verification time are #underline("linear") in _d_ (but should be of $≤ log d$).

#linebreak()

Now let's look of the usage of the polynomial commitments. Let's start with an interesting observation.

For a non-zero $f in FF^(≤d)_p[X]$ and for $r <- FF_p$:

#stroke-block([
  (\*) $P[f(r) = 0] ≤ d "/" p$
])

So, the proability that a randomly samples _r_ in the finite field $FF_p$ is one of the roots of the degrees in a polynomial as at most the number of roots divided by the number of values in the field.
Therefore for $r <- FF_p$: if $f(r) = 0$ then $f$ is most likely identically zero.

Another useuful observation is:

#stroke-block([
  *SZDL lemma*: (\*) also holds for #underline("multvariate") polynomial (where _d_ is the total degree of _f_)
])

*Proof: TODO*

Based on the observaton aboce we can prove that two functions are identical.

Suppose p $tilde.equiv 2^256$ and $d lt.eq 2^40$ so that $d/p$ is negligible.
Consequently, let $f, g in FF^(lt.eq d)_p[X]$. \
Then for $r <- FF_p$ if $f(r) = g(r)$ then $f = g$ with high proability. This holds because

$f(r) = g(r) => f(r) - g(r) = 0 => f - g = 0 => f = g$. This gives a simple equality test protocol.

Now let's look at the protocol of the two committed polynomials.


#align(center,
  diagram(
    spacing: 2em,
    node-stroke: 0.5pt,
    node((0, 0), [$f, g in FF^(lt.eq d)_p[X]$], stroke: 0pt),
    edge("->", [commitment]),
    node((4, 0), [$"com"_f, "com"_g$], stroke: 0pt),
    node((0, 1), [$y <- f(r) \ y' <- g(r)$], stroke: 0pt),
    edge("<-", [$r$]),
    node((4, 1), [$r <- R$], stroke: 0pt),
    node((0, 2), [$(y, pi_f), (y', pi_g)$], stroke: 0pt),
    edge((0, 2.5), (4, 2.5), "->", [$(y, pi_f), (y', pi_g)$]),
    node((4, 2), [Accept if \ $pi_f, pi_g$ are valid \ and $y = y'$], 
      stroke: 0pt),
    node((0, 3), [Prover], stroke: 0pt),
    node((4, 3), [Verifier], stroke: 0pt),
    node(enclose: ((0, 0), (0, 3))),
    node(enclose: ((4, 0), (4, 3)))
  )
)

Where $pi_f$ and $pi_g$ are the proves that the $y = f(r)$ and $y' = g(r)$ respectively.

#pagebreak()

== Fiat-Shamir Transform

This allows us to make a protocol non-interactive. However, it isn't secure for every protocol.

We are going to start by using a cryptographic hash function $H: M -> R$. The prover will then use
this function to generate verifier's random bits on its own using _H_.

The protocol becomes as follows:

- Let's $x = ("com"_f, "com"_g)$, and $w = (f, g)$

- The prover computes _r_, such that $r <- H(x)$

- The prover then computes $y <- f(r), y' <- g(r)$ and generates $pi_f, pi_g$

- The prover sends $y, y', pi_f, pi_g$ to verifier.

- The verifier can now also compute $r <- H(x)$ from $("com"_f, "com"_g)$ and verify the proof.

To prove knowledge soundness, we need to solve a theorem that the given protocol is a SNARK if
1. _d_ / _p_ is negligible (where $f, g in FF^(lt.eq d)_(p)[X]$)
2. _H_ is modelled as a random oracle.

In practice, _H_ is described as SHA256.

= Internative Oracle Proofs ($F$-IOP)

*Functional Commitment Schemes* allows us to commit to a function whereas *Interactive Oracle Proofs* allows us to boost the commitment into a SNARK for general circuits.

As an example we can take a polynomial scheme for $FF_p^(lt.eq d)[X]$ and, using Poly-IOP, boost into a SNARK for any circuit _C_ where $|C| < d$

Let's define what _F_-IOP is.

Let $C(x, w)$ be some arithemtic circuit and let $x in FF^n_p$. \
_F_-IOP is a proof system that proves $exists w: C(x, w) = 0$ as follows

#stroke-block([
  Setup( _C_ ) $->$ public params _pp_ and _vp_. But public params for a verifier (_vp_) with contain a set of functions that will be replaced with function committments using Functional Commitment scheme. 
  You can think of them as _oracles for functions in F_
])

The set of oracles generated by the verifier can be quearied by it at any time. Remember, that in real SNARK, the oracles are commitmements to functions.

From the prover side, the interaction looks as following:

#align(center,
  diagram(
    spacing: 10em,
    node-stroke: 0.5pt,
    node(enclose: ((0,0), (0,1)), [*Prover* \ $P("pp", x, w)$]),
    node(enclose: ((1,0), (1,1)), [*Verifier* \  $V("vp", x)$ \ $r_1 <- FF_p$ \ till $r_(t-1) <- FF_p$]),
    edge((0, 0), (1, 0), "->", [oracle $f_1 in F$]),
    edge((0, 0.2), (1, 0.2), "<-", [$r_1$]),
    edge((0, 0.4), (1, 0.4), "->", [oracle $f_2 in F$]),
    edge((0, 0.6), (1, 0.6), "..", []),
    edge((0, 0.8), (1, 0.8), "<-", [$r_(t-1)$]),
    edge((0, 1), (1, 1), "->", [oracle $f_t in F$]),
  )
)

The verifier then proceed the verifcation by computing: $bold("verify"^(f_(-s), ..., f_t)(x, r_1, ..., r_(t-1)))$. ($-s$ is offset index to account for additional functions before $f_1$ that was sent by the prover.) \
It takes a statement _x_ and all randomness that the verifier has sent to the prover., and it's given access to oracle functions that
the verifier has and all the oracle functions that the prover sent as part of a proof. The verifier can evaluate any of the functions at any point and can decide whether to accept the proof or not.


== The IOP flavour

*Poly-IOP*

- Sonic
- Marlin
- Plonk
- etc

*Multilinear-IOP*

- Spartan
- Clover
- Hyperplonk
- etc

*Vector-IOP*

- STARK
- Breakdown
- Orion
- etc

(*Poly-IOP* + Poly-comit || *Multilinear-IOP* + Multilinear-Commit || *Vector-IOP* + Merkle) + *Fiat-Shamir Transform* = *SNARK*

= Reading 

- #link("https://a16zcrypto.com/posts/article/zero-knowledge-canon", "a16z reading list")