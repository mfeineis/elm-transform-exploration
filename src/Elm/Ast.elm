module Elm.Ast exposing (Node, parse, toString)

import Char
import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , Trailing(..)
        , lazy
        , spaces
        )
import Set


type Node
    = ModuleDeclaration String Exposed


type Exposed
    = All
    | None
    | Some (List ExposedName)


type ExposedName
    = Opaque String
    | Transparent String
    | Simple String


moduleName : Parser String
moduleName =
    Parser.variable
        { start = Char.isUpper
        , inner = \c -> Char.isAlphaNum c || c == '.'
        , reserved = Set.empty
        }


exportName : Parser ExposedName
exportName =
    Parser.oneOf
        [ Parser.succeed Simple
            |= Parser.variable
                { start = Char.isLower
                , inner = Char.isAlphaNum
                , reserved = Set.empty
                }
        , Parser.succeed (\name x -> if x then Transparent name else Opaque name)
            |= Parser.variable
                { start = Char.isUpper
                , inner = \c -> Char.isAlphaNum c
                , reserved = Set.empty
                }
            |. spaces
            |= Parser.oneOf
                [ Parser.succeed True
                    |. Parser.keyword "(..)"
                , Parser.succeed False
                ]
        ]


exposingList : Parser (List ExposedName)
exposingList =
    Parser.sequence
        { start = "("
        , separator = ","
        , end = ")"
        , spaces = spaces
        , item = exportName
        , trailing = Forbidden
        }


moduleDeclaration : Parser Node
moduleDeclaration =
    Parser.succeed ModuleDeclaration
        |. spaces
        |. Parser.keyword "module"
        |. spaces
        |= moduleName
        |. spaces
        |. Parser.keyword "exposing"
        |. spaces
        |= Parser.oneOf
            [ Parser.succeed Some
                |= exposingList
            , Parser.succeed All
                |. Parser.keyword "(..)"
            , Parser.succeed None
            ]
        |. spaces
        |. Parser.end


parse : String -> Result (List Parser.DeadEnd) Node
parse =
    Parser.run moduleDeclaration


toString : a -> String
toString =
    Debug.toString
