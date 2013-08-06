#!/usr/bin/env perl

use strict;
use warnings;
use Text::Markdown 'markdown';
use File::Basename;
use Path::Class;

my $USAGE = 'markdown2revealjs.pl index.md';
die "Usage: $USAGE " unless @ARGV == 1;

my ($mdfile) = @ARGV;
die "${mdfile} not found...\n" unless -f $mdfile;

my $SECTION_RE = qr{(.+[ \t]*\n[-=]+[ \t]*\n*(?:(?!.+[ \t]*\n[-=]+[ \t]*\n*)(?:.|\n))*)};

my $SLIDE_FORMAT = <<"HTML";
<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<title>reveal.js - Barebones</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<link rel="stylesheet" href="css/reveal.min.css">
<link rel="stylesheet" href="css/theme/simple.css" id="theme">
<style type="text/css">
.reveal h1,
.reveal h2,
.reveal h3,
.reveal h4,
.reveal h5,
.reveal h6 {
    margin: 0px 0px 50px 0px;    
}
</style>
</head>
<body>
<div class="reveal">
<div class="slides">
%s
</div>
</div>
<script src="lib/js/head.min.js"></script>
<script src="js/reveal.min.js"></script>
<script>
Reveal.initialize({ center: false, transition: 'none' });
</script>
</body>
</html>
HTML

sub parse_sections {
    my $mdsrc = shift;
    my @sections;
    while ( $mdsrc =~ /$SECTION_RE/g ) {
        push @sections, $1;
    }
    return @sections;
}

my $mdsrc = file($mdfile)->slurp;
my @md_sections = parse_sections($mdsrc);
my @html_sections = ();
foreach my $md_section (@md_sections) {
    push @html_sections, sprintf("<section>\n%s</section>\n\n", markdown($md_section)); 
}

my $slide_html = sprintf $SLIDE_FORMAT, join("", @html_sections);

my ($filename, $dirpath, $fileext) = fileparse($mdfile, qw/.md/);
my $htmlfile = file($dirpath, $filename.'.html');
my $htmlio = $htmlfile->openw;
$htmlio->print($slide_html);
$htmlio->close;

print "created: ", $htmlfile->stringify, "\n";
