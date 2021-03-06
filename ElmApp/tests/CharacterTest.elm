module CharacterTest exposing (all)


import Test exposing (..)
import TestData exposing (..)
import Expect exposing (..)
import List exposing (head, length)
import Maybe exposing (withDefault)

import Character exposing ( Character
                          , affiliate
                          , attrValue
                          , characterFactory
                          , increaseAttribute
                          , increaseSkill
                          , unaffiliate
                          , valid
                          )
import Affiliation exposing (Affiliation)
import Attributes exposing (Attributes, attributesFactory)
import Skill exposing (Skill)


all : Test
all =
  Test.concat
    [ basics, validity, affiliation, skills ]

basics : Test
basics =
  describe "A Character"
    [ test "starts with 5000 XP" <|
        \_ ->
          let
            char = characterFactory
          in
            char.xp `equal` 5000
    , test "can have a different xp specified" <|
        \_ ->
          let
            char = { characterFactory | xp = 3000 }
          in
            char.xp `equal` 3000
    , test "can have a first and last name set" <|
        \_ ->
          let
            char = { characterFactory | firstName = "John", lastName = "Doe" }
          in
            (char.firstName ++ " " ++ char.lastName) `equal` "John Doe"
    , test "should have xp equal to the amount given assigned to the specified attribute" <|
        \_ ->
          let
            char = increaseAttribute characterFactory "str" 120
          in
            (char.attributes.str == 120 && char.xp == 4880) `equal` True
    , test "should return the given character when an invaid attribute is specified" <|
        \_ ->
          let
            char = increaseAttribute characterFactory "wat" 120
          in
            char.xp `equal` 5000
    , test "100XP should have a value of 1 for an attribute" <|
        \_ ->
          let
            char = increaseAttribute characterFactory "str" 100
          in
            attrValue char "str" `equal` 1
    , test "399XP should have a value of 3 for an attribute" <|
        \_ ->
          let
            char = increaseAttribute characterFactory "str" 399
          in
            attrValue char "str" `equal` 3
    ]


affiliation : Test
affiliation =
  let
    affiliation = davionAffiliation
    char = basicCharacter
    affiliatedChar = char `affiliate` affiliation
  in
    describe "A character's affiliations"
      [ test "An affiliation should have a cost to the character" <|
          \_ ->
            affiliatedChar.xp `equal`  4850
      , test "It should get the attribute values from the affiliation" <|
          \_ ->
            affiliatedChar.attributes.str `equal` 125
      , test "Should not add an affiliation that a character already has" <|
          \_ ->
            let
              reAffiliate = affiliatedChar `affiliate` affiliation
            in
              (reAffiliate.xp == 4850 && reAffiliate.attributes.str == 125) `equal` True
      , test "Should be able to remove an affiliation" <|
          \_ ->
            let
              unAff = affiliatedChar `unaffiliate` affiliation
            in
              (unAff.xp == 5000 && unAff.attributes.str == 100) `equal` True
      , test "Should not remove an affiliation it doesn't have" <|
          \_ ->
            let
              newAff = { affiliation | name = "Steiner" }
              unAff = affiliatedChar `unaffiliate` newAff
            in
              (unAff.xp == 4850 && unAff.attributes.str == 125) `equal` True
      , test "Should get it's affiliation's skill(s)" <|
          \_ ->
            List.length affiliatedChar.skills `equal` 1
      ]

validity : Test
validity =
  describe "A Character's validity"
    [ test "should not be valid without a first and last name" <|
        \_ ->
          (valid characterFactory) `equal` False
    , test "should not be valid with negative xp" <|
        \_ ->
          let
            char = { characterFactory | xp = -10 }
          in
            (valid char) `equal` False
    , test "a concept should not be required to be valid" <|
        \_ ->
          let
            char = basicCharacter
          in
            (valid char) `equal` True
    ]

skills : Test
skills =
  let
    char = characterFactory
    skill = acrobaticsSkill
    charWithSkill = increaseSkill char skill 0
  in
    describe "Adding Skills to a character"
      [ test "should add the skill, if the character doesn't already have it" <|
          \_ ->
            charWithSkill.skills `equal` [ skill ]
      , test "should not add a skill it already has" <|
          \_ ->
            let
              newChar = increaseSkill charWithSkill skill 40
            in
              length newChar.skills `equal` 1
      , test "should increase a skill, if the character already has it" <|
          \_ ->
            let
              newChar  = increaseSkill charWithSkill skill 40
              theSkill = withDefault { skill | xp = 0 } (head newChar.skills)
            in
              theSkill.xp `equal` 80
      ]
