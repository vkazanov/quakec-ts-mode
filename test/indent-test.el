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
         (unless (treesit-ready-p 'quakec)
           (treesit-install-language-grammar 'quakec))
         ,@body)))

(ert-deftest quakec-ts-mode-test-indent ()
  (with-quakec-grammar
   (ert-test-erts-file (ert-resource-file "indent.erts"))))

(ert-deftest quakec-ts-mode-test-indent-expression ()
  (with-quakec-grammar
   (ert-test-erts-file (ert-resource-file "indent-expression.erts"))))
