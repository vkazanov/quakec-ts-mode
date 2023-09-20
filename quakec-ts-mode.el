;;; quakec-mode.el --- Major mode for editing QuakeC with tree-sitter  -*- coding: utf-8; lexical-binding: t; -*-

(defvar quakec-ts-mode-indent-offset 4)

(defvar quakec-ts-indent-rules
  `((quakec
     ((parent-is "source_file") column-0 0)
     ((node-is ")") parent 1)
     ((node-is "]") parent-bol 0)

     ;; compound statements
     ;; opening brace
     ((node-is "compound_statement") standalone-parent 0)
     ;; closing brace, should happen before the compound_statement checks
     ((node-is "}") standalone-parent 0)
     ;; case/default is a special case that should begin where a parent
     ;; compound_statement begins
     ((node-is "case") parent-bol 0)

     ((or (match nil "compound_statement" nil 1 1)
          (match null "compound_statement"))
      standalone-parent quakec-ts-mode-indent-offset)
     ((parent-is "compound_statement") prev-sibling 0)

     ;; simple statements
     ((node-is "else") parent-bol 0)
     ((parent-is "if_statement") standalone-parent quakec-ts-mode-indent-offset)
     ((and (node-is "while") (parent-is "do_while_statement")) parent-bol 0)
     ((parent-is "do_while_statement") standalone-parent quakec-ts-mode-indent-offset)
     ((parent-is "while_statement") standalone-parent quakec-ts-mode-indent-offset)
     ((parent-is "for_statement") standalone-parent quakec-ts-mode-indent-offset)
     ((parent-is "case_statement") standalone-parent quakec-ts-mode-indent-offset)

     ;; function definition/declaration parameters
     ((parent-is "parameter_list") first-sibling 1)

     ;; expressions
     ;; ((parent-is "funcall_expression") first-sibling 1)
     ((query "(funcall_expression arg: (_) @indent)") parent quakec-ts-mode-indent-offset)
     ;; ((query "(funcall_expression arg: (_) @indent)") prev-sibling 0)
     ((node-is "funcall_expression") parent 0)
     )))

(defvar quakec-ts-mode--syntax-table
  (let ((table (make-syntax-table)))
    ;; Adapted from c-ts-mode
    (modify-syntax-entry ?_  "_"     table)
    (modify-syntax-entry ?\\ "\\"    table)
    (modify-syntax-entry ?+  "."     table)
    (modify-syntax-entry ?-  "."     table)
    (modify-syntax-entry ?=  "."     table)
    (modify-syntax-entry ?%  "."     table)
    (modify-syntax-entry ?<  "."     table)
    (modify-syntax-entry ?>  "."     table)
    (modify-syntax-entry ?&  "."     table)
    (modify-syntax-entry ?|  "."     table)
    (modify-syntax-entry ?\240 "."   table)
    (modify-syntax-entry ?/  ". 124b" table)
    (modify-syntax-entry ?*  ". 23"   table)
    (modify-syntax-entry ?\n "> b"  table)
    (modify-syntax-entry ?\^m "> b" table)
    table)
  "Syntax table for `quakec-ts-mode'.")


(defvar quakec-ts-font-lock-rules
  '(:language
    quakec
    :override t
    :feature comment
    ((comment) @font-lock-comment-face)

    :language
    quakec
    :override t
    :feature literal
    (((numeric_literal) @font-lock-number-face)
     ((builtin_literal) @font-lock-number-face)
     ((string_literal) @font-lock-string-face))

    :language
    quakec
    :override t
    :feature keyword
    (["break" "return" "continue"
      "enum" "class"
      "nosave" "local"
      "if" "else" "for" "while" "do" "switch" "case" "default"]
     @font-lock-keyword-face)

    ;; TODO: catches wrong lower case (e.g. enum name, also doesn't
    ;; work in expressions), to be debugged as the regexp engine is on
    ;; emacs

    ;; :language
    ;; quakec
    ;; :override t
    ;; :feature constant
    ;; (((identifier) @font-lock-constant-face
    ;;   (:match "[A-Z_][A-Z\\d_]*" @font-lock-constant-face)))

    :language
    quakec
    :override t
    :feature operator
    ((field_expression
      operator: ["." "->"] @font-lock-operator-face
      field: (identifier) @font-lock-variable-name-face)

     ["--" "-" "-=" "->" "=" "!=" "*" "&" "&&" "+" "++" "+=" "<" "==" ">" "||" ]
     @font-lock-operator-face)

    :language
    quakec
    :override t
    :feature punctuation
    ([";" ":" "..."] @font-lock-punctuation-face)

    :language
    quakec
    :override t
    :feature bracket
    (["(" ")" "{" "}" "[" "]"] @font-lock-bracket-face)

    :language
    quakec
    :override t
    :feature preprocessor
    (["#define" "#undef" "#ifdef" "#ifndef" "#else" "#endif"]
     @font-lock-preprocessor-face)

    :language
    quakec
    :override t
    :feature type
    ((simple_type) @font-lock-type-face)

    :language
    quakec
    :override t
    :feature variable
    ((variable_definition
      name: (identifier) @font-lock-variable-name-face)
     (field_definition
      name: (identifier) @font-lock-variable-name-face)
     (parameter
      name: (identifier) @font-lock-variable-name-face)

     (assignment_expression
      target: (identifier) @font-lock-variable-use-face)
     (field_expression
      argument: (identifier) @font-lock-variable-use-face
      field: (identifier) @font-lock-variable-use-face)
     (unary_expression
      target: (identifier) @font-lock-variable-use-face)
     (update_expression
      target: (identifier) @font-lock-variable-use-face)
     (binary_expression
      left: (identifier) @font-lock-variable-use-face)
     (binary_expression
      right: (identifier) @font-lock-variable-use-face))

    :language
    quakec
    :override t
    :feature function-name
    ((function_declaration
      name: (identifier) @font-lock-function-name-face)
     (function_definition
      name: (identifier) @font-lock-function-name-face)
     (funcall_expression
      function: (identifier) @font-lock-function-name-face)
     (funcall_expression
      function: (field_expression field: (identifier) @font-lock-function-name-face)))

    :language
    quakec
    :override t
    :feature builtin
    (((identifier) @font-lock-builtin-face
      (:equal "self" @font-lock-builtin-face)))
    ))

(define-derived-mode quakec-ts-mode prog-mode "QuakeC-ts"
  "Major mode for editing QuakeC files with tree-sitter."
  :syntax-table quakec-ts-mode--syntax-table

  ;; TODO: syntax table?
  ;; :syntax-table quakec-ts-mode-syntax-table

  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'quakec)
    (treesit-parser-create 'quakec)
    (quakec-ts-setup)))

(defun quakec-defun-name-function (node)
  (let ((node-type-text (treesit-node-type node)))
    (when (equal node-type-text "function_definition")
      (treesit-node-text (treesit-node-child-by-field-name node "name")))))

(defun quakec-ts-imenu-name-function (node)
  (treesit-node-text (treesit-node-child-by-field-name node "name")))

(defun quakec-ts-setup ()
  "Setup treesit for -ts-mode."

  ;; font-locking
  ;;

  (setq-local treesit-font-lock-settings
              (apply #'treesit-font-lock-rules
                     quakec-ts-font-lock-rules))

  ;; TODO: come up with a list of things to highlight
  (setq-local treesit-font-lock-feature-list
              '((comment)
                (operator type constant keyword literal preprocessor)
                (function-name variable punctuation bracket)
                (delimiter builtin)))

  ;; indentation
  ;;

  ;; TODO: finish
  (setq-local treesit-simple-indent-rules quakec-ts-indent-rules)

  ;; imenu
  ;;

  (setq-local treesit-simple-imenu-settings
              '(("Function" "function_\\(definition\\|declaration\\)" nil  quakec-ts-imenu-name-function)
                ("Variable" "variable_definition" nil  quakec-ts-imenu-name-function)
                ("Field" "field_definition" nil  quakec-ts-imenu-name-function)))

  ;; Auxilary
  ;;

  (setq-local treesit-defun-type-regexp "function_definition")
  (setq-local treesit-defun-name-function #'quakec-defun-name-function)


  ;; mandatory
  ;;
  (treesit-major-mode-setup))




(provide 'quakec-ts-mode)
