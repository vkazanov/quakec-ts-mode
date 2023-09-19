;;; Code:

(require 'ert)
(require 'ert-x)
(require 'treesit)

(ert-deftest quakec-ts-mode-test-indentation ()
  (skip-unless (treesit-ready-p 'quakec))
  (ert-test-erts-file (ert-resource-file "indent.erts")))
