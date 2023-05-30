use Test;
plan 1;
use Font::FreeType;
use experimental :rakuast;

todo "RakuAST development";
lives-ok {'examples/glyph-to-eps.raku'.IO.slurp.AST }


