(lang dune 2.9)
(using menhir 2.1)
(generate_opam_files true)

(source (github TokTok/apidsl))
(license GPL3)
(authors "Iphy Df")
(maintainers "iphydf@gmail.com")

(package
 (name apidsl)
 (synopsis "Domain Specific Language to describe C APIs")
 (description "Domain Specific Language to describe C APIs")
 (depends
  (dune (>= 2.9.1))
  (bisect_ppx (> 0.1))
  (js_of_ocaml-ppx (> 0.1))
  (menhirLib (>= 20200211))
  (ppx_deriving_yojson (> 0.1))
  (tiny_httpd (>= 0.9))
  (yojson (>= 1.7.0))))
