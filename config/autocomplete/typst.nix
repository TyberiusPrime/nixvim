# typst snippets (friendly-snippets has none), see default.nix for the format
{
  setup = {
    prefix = "setup";
    body = [
      "#set document(title: \"\${1:Title}\", author: \"\${2:Florian}\")"
      "#set page(paper: \"a4\", numbering: \"1\")"
      "#set text(lang: \"\${3:de}\", size: 11pt)"
      "#set heading(numbering: \"1.1\")"
      ""
      "$0"
    ];
    description = "document/page/text/heading setup";
  };
  import = {
    prefix = "import";
    body = "#import \"\${1:@preview/}\": \${2:*}";
    description = "#import package or file";
  };
  "let" = {
    prefix = "let";
    body = "#let \${1:name}(\${2:args}) = \${0:body}";
    description = "#let function";
  };
  show = {
    prefix = "show";
    body = "#show \${1:heading}: \${2:it => it}";
    description = "#show rule";
  };
  figure = {
    prefix = "fig";
    body = [
      "#figure("
      "  image(\"\${1:path}\", width: \${2:80%}),"
      "  caption: [\${3:caption}],"
      ") <fig:\${4:label}>"
    ];
    description = "figure with image, caption and label";
  };
  table = {
    prefix = "table";
    body = [
      "#table("
      "  columns: \${1:3},"
      "  table.header[\${2:A}][\${3:B}][\${4:C}],"
      "  $0"
      ")"
    ];
    description = "table with header row";
  };
  grid = {
    prefix = "grid";
    body = [
      "#grid("
      "  columns: (\${1:1fr, 1fr}),"
      "  gutter: \${2:1em},"
      "  [\${3}], [\${4}],"
      ")"
    ];
    description = "grid layout";
  };
  subparimport = {
    prefix = "subparimport";
    body = "#import \"@preview/subpar:0.2.2\"";
    description = "import subpar";
  };
  subpar = {
    prefix = "subpar";
    body = [
      "#subpar.grid("
      "  figure(image(\"\${1:path_a}\"), caption: [\${2:caption a}]), <fig:\${3:a}>,"
      "  figure(image(\"\${4:path_b}\"), caption: [\${5:caption b}]), <fig:\${6:b}>,"
      "  columns: (\${7:1fr, 1fr}),"
      "  caption: [\${8:caption}],"
      "  label: <fig:\${9:label}>,"
      ")"
    ];
    description = "subpar.grid with two labelled sub-figures (needs subparimport)";
  };
  math = {
    prefix = "mathblock";
    body = [
      "\\$ \${1} \\$ <eq:\${2:label}>" # literal $ must be escaped in snippets
    ];
    description = "display math with label";
  };
  link = {
    prefix = "link";
    body = "#link(\"\${1:https://}\")[\${2:text}]";
    description = "#link with text";
  };
  code = {
    prefix = "code";
    body = [
      "```\${1:python}"
      "\${0}"
      "```"
    ];
    description = "raw code block";
  };
  footnote = {
    prefix = "fn";
    body = "#footnote[\${1}]";
    description = "footnote";
  };
  bib = {
    prefix = "bib";
    body = "#bibliography(\"\${1:refs.bib}\")";
    description = "bibliography";
  };
}
