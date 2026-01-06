defmodule BechamelTest do
  use ExUnit.Case
  doctest Bechamel

  test "encoding" do
    addr =
      Bechamel.encode(
        "ckt",
        <<1, 0, 248, 233, 196, 92, 241, 52, 177, 249, 178, 100, 1, 226, 254, 133, 46, 33, 214,
          246, 151, 234>>
      )

    assert addr === "ckt1qyq036wytncnfv0ekfjqrch7s5hzr4hkjl4qd3tkj9"
  end

  test "decoding" do
    assert {:ok, "ckb",
            <<1, 0, 248, 233, 196, 92, 241, 52, 177, 249, 178, 100, 1, 226, 254, 133, 46, 33, 214,
              246, 151, 234>>} === Bechamel.decode("ckb1qyq036wytncnfv0ekfjqrch7s5hzr4hkjl4qs54f7e")
  end

  test "valid_predicate? returns true for valid addresses" do
    assert Bechamel.valid_predicate?("ckb1qyqdmeuqrsrnm7e5vnrmruzmsp4m9wacf6vsxasryq") == true
    assert Bechamel.valid_predicate?("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4") == true
    assert Bechamel.valid_predicate?("a12uel5l") == true
  end

  test "valid_predicate? returns false for invalid addresses" do
    assert Bechamel.valid_predicate?("invalid") == false
    assert Bechamel.valid_predicate?("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5") == false
    assert Bechamel.valid_predicate?("") == false
  end

  test "valid_predicate? handles non-string input without crashing" do
    assert Bechamel.valid_predicate?(nil) == false
    assert Bechamel.valid_predicate?(123) == false
    assert Bechamel.valid_predicate?([1, 2, 3]) == false
    assert Bechamel.valid_predicate?(%{}) == false
    assert Bechamel.valid_predicate?(:atom) == false
  end

  test "verify handles non-string input without crashing" do
    assert {:error, :invalid_input} = Bechamel.verify(nil)
    assert {:error, :invalid_input} = Bechamel.verify(123)
    assert {:error, :invalid_input} = Bechamel.verify([1, 2, 3])
    assert {:error, :invalid_input} = Bechamel.verify(%{})
    assert {:error, :invalid_input} = Bechamel.verify(:atom)
  end

  test "decode handles non-string input without crashing" do
    assert {:error, :invalid_input} = Bechamel.decode(nil)
    assert {:error, :invalid_input} = Bechamel.decode(123)
    assert {:error, :invalid_input} = Bechamel.decode([1, 2, 3])
    assert {:error, :invalid_input} = Bechamel.decode(%{})
    assert {:error, :invalid_input} = Bechamel.decode(:atom)
  end

  test "segwit_decode handles non-string input without crashing" do
    assert {:error, :invalid_input} = Bechamel.segwit_decode(nil, "bc1test")
    assert {:error, :invalid_input} = Bechamel.segwit_decode("bc", nil)
    assert {:error, :invalid_input} = Bechamel.segwit_decode(123, "bc1test")
    assert {:error, :invalid_input} = Bechamel.segwit_decode("bc", 123)
    assert {:error, :invalid_input} = Bechamel.segwit_decode(:atom, :atom)
  end

  test "ignore_length option allows addresses over 90 characters" do
    # Create a long data payload (50 bytes = 80 chars in bech32 encoding, plus hrp and checksum > 90)
    long_data = :binary.copy(<<1, 2, 3, 4, 5>>, 10)
    long_addr = Bechamel.encode("ckb", long_data)

    # Verify the address is actually over 90 characters
    assert byte_size(long_addr) > 90

    # Without ignore_length, should fail
    assert {:error, :too_long} = Bechamel.decode(long_addr)

    # With ignore_length: true, should succeed
    assert {:ok, "ckb", _data} = Bechamel.decode(long_addr, ignore_length: true)
  end

  describe "BIP-173 valid Bech32 test vectors" do
    test "uppercase A12UEL5L (lowercased for verify)" do
      assert :ok = Bechamel.verify(String.downcase("A12UEL5L"))
    end

    test "lowercase a12uel5l" do
      assert :ok = Bechamel.verify("a12uel5l")
    end

    test "83 character HRP with excluded chars in name" do
      assert :ok =
               Bechamel.verify(
                 "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs"
               )
    end

    test "abcdef with full charset in data" do
      assert :ok = Bechamel.verify("abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw")
    end

    test "HRP of 1 with long data" do
      assert :ok =
               Bechamel.verify(
                 "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j"
               )
    end

    test "split checkup address" do
      assert :ok = Bechamel.verify("split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w")
    end
  end

  describe "BIP-173 invalid Bech32 test vectors" do
    test "84 chars - overall max length exceeded" do
      assert {:error, :too_long} =
               Bechamel.decode(
                 "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx"
               )
    end

    test "no separator character" do
      assert {:error, :no_separator} = Bechamel.decode("pzry9x0s0muk")
    end

    test "empty HRP (1 at start)" do
      assert {:error, :no_hrp} = Bechamel.decode("1pzry9x0s0muk")
    end

    test "invalid data character (b)" do
      assert {:error, :not_in_charset} = Bechamel.decode("x1b4n0q5v")
    end

    test "too short checksum" do
      assert {:error, :checksum_too_short} = Bechamel.decode("li1dgmt3")
    end

    test "checksum calculated with uppercase form of HRP" do
      assert {:error, :checksum_failed} = Bechamel.decode("A1G7SGD8")
    end

    test "empty HRP - 10a06t8" do
      assert {:error, :no_hrp} = Bechamel.decode("10a06t8")
    end

    test "empty HRP - 1qzzfhee" do
      assert {:error, :no_hrp} = Bechamel.decode("1qzzfhee")
    end

    test "HRP character out of range (0x20 space)" do
      assert {:error, :invalid_char} = Bechamel.decode(" 1nwldj5")
    end

    test "mixed case" do
      assert {:error, :mixed_case_char} = Bechamel.decode("A1a")
    end
  end

  describe "BIP-173 valid SegWit test vectors" do
    test "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4" do
      {:ok, witver, data} =
        Bechamel.segwit_decode("bc", "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4")

      assert witver == 0
      assert Base.encode16(data, case: :lower) == "751e76e8199196d454941c45d1b3a323f1433bd6"
    end

    test "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7" do
      {:ok, witver, data} =
        Bechamel.segwit_decode(
          "tb",
          "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7"
        )

      assert witver == 0

      assert Base.encode16(data, case: :lower) ==
               "1863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262"
    end

    test "BC1SW50QA3JX3S" do
      {:ok, witver, data} = Bechamel.segwit_decode("bc", "BC1SW50QA3JX3S")
      assert witver == 16
      assert Base.encode16(data, case: :lower) == "751e"
    end

    test "bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj" do
      {:ok, witver, data} = Bechamel.segwit_decode("bc", "bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj")
      assert witver == 2
      assert Base.encode16(data, case: :lower) == "751e76e8199196d454941c45d1b3a323"
    end

    test "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy" do
      {:ok, witver, data} =
        Bechamel.segwit_decode(
          "tb",
          "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy"
        )

      assert witver == 0

      assert Base.encode16(data, case: :lower) ==
               "000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433"
    end
  end

  describe "BIP-173 invalid SegWit test vectors" do
    test "invalid HRP (tc instead of tb or bc)" do
      assert {:error, :wrong_hrp} =
               Bechamel.segwit_decode("bc", "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty")
    end

    test "invalid checksum" do
      assert {:error, :checksum_failed} =
               Bechamel.segwit_decode("bc", "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5")
    end

    test "invalid witness version (31)" do
      assert {:error, :invalid_witness_version} =
               Bechamel.segwit_decode("bc", "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2")
    end

    test "invalid program length (too short)" do
      assert {:error, :invalid_size} = Bechamel.segwit_decode("bc", "bc1rw5uspcuh")
    end

    test "invalid program length (too long)" do
      assert {:error, :invalid_size} =
               Bechamel.segwit_decode(
                 "bc",
                 "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90"
               )
    end

    test "invalid program length for witness version 0" do
      assert {:error, :invalid_size} =
               Bechamel.segwit_decode("bc", "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P")
    end

    test "mixed case in address" do
      assert {:error, :mixed_case_char} =
               Bechamel.segwit_decode(
                 "tb",
                 "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7"
               )
    end

    test "empty data section" do
      assert {:error, _reason} = Bechamel.segwit_decode("bc", "bc1gmk9yu")
    end
  end
end
