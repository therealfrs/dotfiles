require("coq_3p") {
  { src = "nvimlua", short_name = "nLUA", conf_only=false },
  { src = "bc", short_name = "MATH", precision = 4 }
}

vim.g.coq_settings = {
    auto_start = "shut-up",
}
