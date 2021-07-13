# ================================================
# command : t_html.pl
# author  : taizod
# updated : 2011-06-07T10:15:05+09:00
# comment : テキストファイルのHTML化スクリプト
# ================================================


my $name = $ARGV[0];

my $text = '';
while (<STDIN>) { $text .= $_; }

my $header = <<END_OF_HEADER;
<!doctype html public "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja-JP">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="Content-Style-Type" content="text/css">
    <meta http-equiv="Content-Script-Type" content="text/javascript">
    <base href="http://tsofthome.appspot.com/">
    <link rel="stylesheet" href="style/base.css" type="text/css">
    <link rel="shortcut icon" href="image/favicon.ico">
    <title>$name</title>
  </head>
  <body>
    <div class="s0">
      <h1>$name</h1>
    </div>
    <hr>
    <div class="s0">
      <a href="/">インデックス</a> ≫
      <a href="ecmascript.html">ECMA-262第5版 日本語訳</a> ≫
      $name
    </div>
    <hr>
    <pre>
END_OF_HEADER

my $footer = <<END_OF_FOOTER;
    </pre>
    <hr>
    <div class="s0">
      Copyright 2012 YAMAMOTO TAIZO All Rights Reserved.
    </div>
  </body>
</html>
END_OF_FOOTER

$text =~ s/\&/&amp;/mg;
$text =~ s/\>/&gt;/mg;
$text =~ s/\</&lt;/mg;
$text = $header . $text .$footer;

print $text;
