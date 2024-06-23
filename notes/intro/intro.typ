#import "../base.typ": *
#show: note

= Introduction to Zero Knowledge Proofs

There are a prover and verifier
`String` = proof submitted by the prover
Verifier rejects or accepts the proof (i.e. the `String`)

In CS we talk about polynomial proofs, that can be verified in *polynomial* time $->$ *NP proofs*
- The `string` is short
- Polynomial time constraints

Given claim `x`, the length of the proof `w` should be of polynomial length.
More formally: `|w|` = polynomial in `|x|`.

The verifier has a *polynomyial* time contraints for execution.

`V` _accepts_ `w` if $V(x,w) = 1$, otherwise _rejects_.
#align(center,
  diagram(
    spacing: 8em,
    node((0,0), [*Prover* \ Uncontrained runtime]),
    edge("->", [Proof *w*]),
    node((1,0), [*Verifier* \ Verifies in polynomial time of claim `x`]),
  )
)

= Efficently verifiable proofs

We can formalise the the input as:
- Language $L$ - a set of binary strings

More formally:

#def([
  $L$ is an *NP* language (or NP decision problem), if there is a verifier $V$ that runs in polynomial time of length of the claim $x$ that where
  - *Completeness [True claims have short proofs]* \
    if $x in L$, there is a polynomially (of $|x|$) long witness $w in {0,1}^*$ st $V(x,w) = 1$
  - *Soundness [False claims have no proofs]* \
    if $x in.not L$, there is no witness. That is, for all $w in {0,1}^*, V(x,w)=0$
])

= Proving Quadratic Residue #footnote[https://mathworld.wolfram.com/QuadraticResidue.html]

*Goal*: proof that $y$ is a quadratic residue $mod N$.

#align(center,
  diagram(
    spacing: 15em,
    node((0,0), [*Prover*]),
    edge("->", [Proof = $sqrt(y) mod N in Z^*_N$]),
    node((1,0), [*Verifier*]),
  )
)

*The gist:* Prove (or persuade) the verifier that the prover could prove the statement.

Adding additional components - *Interactive* and *Probabilistic* proofs
- *Interaction* - verifier engages in the _non-trivial_ interaction with the prover
- *Randomness* - verifier is randomised, and can accept am invalid proof with a small probability (quantified).

#align(center,
  diagram(
    spacing: 5em,
    node-stroke: 0.5pt,
    node(enclose: ((0,0), (0,1)), [*Prover*]),
    node(enclose: ((1,0), (1,1)), [*Verifier*]),
    edge((0, 0), (1, 0), "->", [Answer]),
    edge((0, 0.3), (1, 0.3), "<-", [Question]),
    edge((0, 0.6), (1, 0.6), "->", [Answer]),
    edge((0, 0.9), (1, 0.9), "<-", [Question]),
    edge((0, 1), (1, 1), "..", []),
  )
)

*Examples*: https://medium.com/@houzier.saurav/non-technical-101-on-zero-knowledge-proofs-cab77d671a40


*Here is the interactive proof for the quadratic residue:*
1. Prover chooses a random $r$ s.t. $1 ≤ r ≤ N$ s.t. $gcd(r, N) = 1$

2. Prover sends $s$, s.t. $s = r^2 mod N$
  - If the prover sends $sqrt(s) mod N$ and $sqrt(s times y) mod N$ later, then the verifier coulde deduce $x = sqrt(y) mod N$
  - Instead, the prover gives either one of the roots.

3. Verifier randomly chooses $b in {0, 1}$

4. if $b=1$: verifier sends $z=r$, otherwise $z=r times sqrt(y) mod N$

5. Verifier accepts the proofs only if $z^2 = s y^b mod n$
  - if $b=0$ then $z^2 = s mod N$
  - otherwise, $z^2 = s y mod N$

During the first try, the probability of error is $1/2$, after $k$ interactions => it is $(1/2)^k$.

*Note*: at the beginning of each interaction, the Prover generates a new $r$ which is $sqrt(s) mod N$

Assessing the properties:
- *Completeness*: if the claim is true, the verifier will accept it.

- *Soundness*:  if the claim is false, $forall$provers, $P("Verifier accepts") ≤ 1/2$

  - After $k$ interactions: $forall$provers, $P("Verifier accepts") ≤ (1/2)^k$ 

= How does previous example worked?

Sending both parts of the QR, proves that the verifier *could* solve the original equation. Additionally, sending just the $s$ reveal no knowledge about the original solution.

The ability of the prover, to provide solution to either part persuades the verifier that it can solve the original equation.

= Interactive Proofs

#align(center,
  diagram(
    spacing: 5em,
    node-stroke: 0.5pt,
    node(enclose: ((0,0), (0,1)), [*Prover*]),
    node(enclose: ((1,0), (1,1)), [*Verifier*]),
    node(enclose: ((0,1.5), (1,1.5)), [*Claim / Theorem X*]),
    edge((0, 0), (1, 0), "->", [$a_1$]),
    edge((0, 0.3), (1, 0.3), "<-", [$q_1$]),
    edge((0, 0.6), (1, 0.6), "->", [$a_2$]),
    edge((0, 0.9), (1, 0.9), "<-", [$q_2$]),
    edge((0, 1), (1, 1), "..", []),
  )
)


#def([
  $(P,V)$ is an interactive proof for $L$, if $V$ is probabilistic $"poly"(|x|)$
  and 
  - *Completeness*: if $x in L$, $P[(P,V)(x) = "accept"] ≥ c$
  - *Soundness*: if $x in.not L$ for every $P^*$, $P[(P^*,V)(x) = "accept"] ≤ s$
  We want to $c$ to be as close to *b* as possible, and $s$ to be as negligible as possible.
  Equivalent as long as $c - s ≥ 1/"poly"(|x|)$
])

#def([
  Class of interaction proof languages = {$L$ for which there is an interactive proof}
])

= Zero-Knowledge views

The intuition behind zero knowledge interactions:

For any true statements, what the verifier can compute *after* the interaction is the same to what it could have computer *before* the interaction. In other words, the verifier *does not gain any more information* (i.e. knowledge) after the verification interaction. This should hold true *even for malicious verifiers.*

View is essentially a set of traces containing submitted questions $q^*$ to the verifier and received answers $a^*$ from it.

After the interaction $V$ learns:
- Theorem (T) is true, $x in L$
- A *view* of interactions

#def([
  *$"view"_v(P,V)[x]$* = ${(q_1, a_1), (q_2, a_2), ...}$, which is a probibility distributions over random values of $V$ and $P$.
])

In the case of $P$, the random value it selects for QR is $r$, in the case of $P$ it is the choice whether the reveal $r$ or $r sqrt(y) mod N$

== Simulation Paradigm

We can say that V's view gives no further knowledge to it, if it could have simulated it on its own s.t. the simulated view and the real view are _computationally indistinguishable_.

What that means is that we can have a polynomial time "distinguisher" that extracts the trace from either of the views, and if it can not differentiate it with the probability less than 50/50, we can say that they views are _computationally indistinguishable_. 


#align(center,
  diagram(
    spacing: 10em,
    node-stroke: 0.5pt,
    node(enclose: ((0, 0), (0,1)), [The poly-time \ Distinguisher]),
    node(enclose: ((1, 0), (1, 1))),
    node((1, 0.2), [Real view], shape: rect),
    node((1, 0.8), [Simulated \ view]),
    edge((0,0.2) , (1, 0.2), "<-", [sample]),
    edge((0,0.8) , (1, 0.8), "<-", [sample])
  )
)

More formally:

#align(center,
  diagram(
    spacing: 10em,
    node-stroke: 0.5pt,
    node(enclose: ((0, 0), (0,1)), [The poly-time \ Distinguisher]),
    node(enclose: ((1, 0), (1, 1))),
    node((1, 0.2), [$D_1$ - k-bit strings]),
    node((1, 0.8), [$D_2$ - k-bit strings]),
    edge((0,0.5) , (1, 0.5), "<-", [sample]),
  )
)

#def([
  For all distinguisher algorithms, even after receiving a polynomial number of samples for $D_b$, if $P("Distinguisher guesses " b) < 1/2 + c$ where $c$ negligible constant, \ then $D_1 .. D_k$ are *computationally indistinguishable*
])

= Zero-Knowledge Definition

#def([
  An Interactive Protocol (P,V) is zero-knowledge for a language $L$ if there exists a *PPT* (Probabilistic Polynomial Time) algorithm *Sim* (a simulator) such that for every $x in L$, the following two probability distributions are
  *poly-time* indistinguishable:
    1. $"view"_v(P,V)[x] = "traces"$

    2. $"Sim"(x, 1^lambda)$

    $(P,V)$ is a zero-knowledge interactive protocol if it is *complete*, *sound* and *zero-knowledge*.
])

Flavours of Zero-Knowledge:
- Computationally indistinguishable distributions = CZK
- Perfectly identical distributions = PZK
- Statistically close distributions = SZK

= Simulator Example

For QR, the view presented as $"view"_v(P,V): (s, b, z)$

Simulator workflow:
1. Pick a random $b$

2. Pick a random $z in Z^*_N$ 

3. Compute $s = z^2 "/" y^b$

4. Output $(s, z, b)$

We would see that $(s, z, b)$ is identically distributed as in real view.

*For adversarial verifier $V^*$:*
1. Pick a random $b$

2. Pick a random $z in Z^*_N$ 

3. Compute $s = z^2 "/" y^b$

4. If $V*(N, y, s) = b$, then output $(s, z, b)$, otherwise go to step 1.

Within 2 iteration, we would still reach identical distribution.

= Proof of knowledge

The prover convinces the verifier not only about the theorem but that it also knows the $x$.

Using that information, we can construct the knowledge extractor using the rewinding technique.

More formally:

#def([
  Consider $L_R = {x : exists w "s.t." R(x, w) = "accept"}$ for poly-time relation $R$.

  $(P,V)$ is a proof of knowledge (POK) for $L_R$ if $exists$ PPT (knowledge) extractor algorithm $E$ s.t. $forall x in L$ in expected poly-time $E^(P)(x)$ outputs $w$ s.t. $V(x, w)$ = accept 
])



#align(center,
  diagram(
    spacing: 12em,
    node-stroke: 0.5pt,
    node(enclose: ((0,0), (0,1)), [*Prover*]),
    node(enclose: ((1,0), (1,1)), [*Verifier*]),
    edge((0, 0), (1, 0), "->", [$s=r^2 mod n$]),
    edge((0, 0.2), (1, 0.2), "<-", [$b=0$]),
    edge((0, 0.4), (1, 0.4), "->", [$r$]),
    edge((0, 0.7), (1, 0.7), "<-", [_In the same cycle of $s$_ \ $b=1$]),
    edge((0, 0.9), (1, 0.9), "->", [$r times sqrt(y) mod N$]),
  )
)

And the verifier can determine $r times sqrt(y) mod N$, hence, extract the knowledge.

= All of NP is in Zero-Knowledge

#def([
  *Theorem[GMW86,Naor]*: If one-way functions exist, then every
  $L in "NP"$ has computational zero knowledge interactive proofs
])

Shown that an NP-Complete Problem has a ZK interactive Proof.

[GMW87] Showed ZK interactive proof for G3-COLOR using bit commitments.

= Reading 

#link("https://link.springer.com/chapter/10.1007/3-540-47721-7_11", "How to Prove All NP Statements in Zero-Knowledge and a Methodology of Cryptographic Protocol Design (Extended Abstract)")