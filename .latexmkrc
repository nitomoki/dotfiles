#!/usr/bin/perl
$latex = 'platex -kanji=utf-8 -synctex=1 -halt-on-error -interaction=nonstopmode';
$bibtex = 'pbibtex';
$dvipdf = 'dvipdfmx %O -o %D %S';
$pdf_mode = 3; # use dvipdf
$pdf_update_method = 2;
$pdf_previewer = "start mupdf %O %S";
$max_repeat       = 5;
$pvc_view_file_via_temporary = 0;
