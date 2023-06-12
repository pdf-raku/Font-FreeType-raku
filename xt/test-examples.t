use Test;
plan 1;
use Font::FreeType;
use experimental :rakuast;

# doesn't work on Rakudo blead yet
todo "RakuAST development";
lives-ok { 'examples/glyph-to-eps.raku'.IO.slurp.AST }


