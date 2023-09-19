;;; Code:

(require 'ert)
(require 'ert-x)
(require 'treesit)

(require 'quakec-ts-mode)

(defmacro with-quakec-grammar (&rest body)
  (declare (indent 0))
  `(unwind-protect
       (progn
         (cl-pushnew '(quakec "https://github.com/vkazanov/tree-sitter-quakec.git")
                     treesit-language-source-alist)
         (treesit-install-language-grammar 'quakec)
         ,@body)))

(ert-deftest quakec-ts-mode-test-indentation ()
  (with-quakec-grammar
    (skip-unless (treesit-ready-p 'quakec))
    (ert-test-erts-file (ert-resource-file "indent.erts"))))
