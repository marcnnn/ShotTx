defmodule ShotTx.Prover.LemmaTest do
  use ShotTx.Test.ProverCase

  @problem ~p"""
  thf(p_t, type, p: $o).
  thf(q_t, type, q: $o).
  thf(a, axiom, p => q).
  thf(c, conjecture, q).
  """

  # The lemma's term id, hash-consed against the same declaration of `p`.
  defp lemma_p do
    [{_, p}] = ~p"thf(p_t, type, p: $o). thf(l, axiom, p).".axioms
    p
  end

  test "without the lemma the conjecture has a countermodel" do
    assert_csa(@problem)
  end

  test "a lemma from the lemma table closes the proof, and the proof shows it" do
    table = :ets.new(:lemmas, [:ordered_set, :public])
    :ets.insert(table, {1, lemma_p()})

    proof = assert_thm(@problem, lemma_table: table)
    assert ShotTx.Proof.to_text(proof) =~ "lemma"
  end

  test "an empty lemma table changes nothing" do
    table = :ets.new(:lemmas, [:ordered_set, :public])
    assert_csa(@problem, lemma_table: table)
  end
end
