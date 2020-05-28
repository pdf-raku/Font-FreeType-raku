constant DocRoot = "https://pdf-raku.github.io";

sub resolve-class(Str() $class where .starts-with('Font::FreeType')) {
    my @path = $class.split('::');
    @path[0] = DocRoot;
    @path[1] = 'Font-FreeType-raku';
    @path.join: '/';
}

s:g:s/ '](' ('Font::FreeType'['::'*%%<ident>]) ')'/{'](' ~ resolve-class($0) ~ ')'}/;
