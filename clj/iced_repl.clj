(ns iced-repl
  (:require [nrepl.cmdline :as cmd]))

(def middlewares
  ["cider.nrepl/wrap-complete"
   "cider.nrepl/wrap-debug"
   "cider.nrepl/wrap-format"
   "cider.nrepl/wrap-info"
   "cider.nrepl/wrap-macroexpand"
   "cider.nrepl/wrap-ns"
   "cider.nrepl/wrap-out"
   "cider.nrepl/wrap-pprint"
   "cider.nrepl/wrap-pprint-fn"
   "cider.nrepl/wrap-spec"
   "cider.nrepl/wrap-test"
   "cider.nrepl/wrap-trace"
   "cider.nrepl/wrap-undef"
   "cider.piggieback/wrap-cljs-repl"
   "refactor-nrepl.middleware/wrap-refactor"
   "iced.nrepl/wrap-iced"])

(defn -main []
  (cmd/-main "-m" (pr-str middlewares)))
