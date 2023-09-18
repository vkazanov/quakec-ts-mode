;;; quakec-mode.el --- Major mode for editing QuakeC with tree-sitter  -*- coding: utf-8; lexical-binding: t; -*-

(defvar quakec-ts-font-lock-rules
  '(:language
    quakec
    :override t
    :feature comment
    ((comment) @font-lock-comment-face)

    :language
    quakec
    :override t
    :feature numeric_literal
    ((numeric_literal) @font-lock-number-face)

    :language
    quakec
    :override t
    :feature builtin_literal
    ((builtin_literal) @font-lock-number-face)

    :language
    quakec
    :override t
    :feature string_literal
    ((string_literal) @font-lock-string-face)

    :language
    quakec
    :override t
    :feature keyword
    (["break" "return" "continue" "enum" "for" "while" "do" "class" "nosave"]
     @font-lock-keyword-face)

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
    ([(variable_definition
       name: (identifier) @font-lock-variable-name-face)
      (field_definition
       name: (identifier) @font-lock-variable-name-face)
      (parameter
       name: (identifier) @font-lock-variable-name-face)

      (assignment_expression
       target: (identifier) @font-lock-variable-use-face)
      (field_expression
       field: (identifier) @font-lock-variable-use-face)
      (unary_expression
       target: (identifier) @font-lock-variable-use-face)
      (update_expression
       target: (identifier) @font-lock-variable-use-face)
      (binary_expression
       left: (identifier) @font-lock-variable-use-face)
      (binary_expression
       right: (identifier) @font-lock-variable-use-face)])

    :language
    quakec
    :override t
    :feature function-name
    ([(function_declaration
       name: (identifier) @font-lock-function-name-face)
      (function_definition
       name: (identifier) @font-lock-function-name-face)
      (funcall_expression
       function: (identifier) @font-lock-function-name-face)
      (funcall_expression
       function: (field_expression field: (identifier) @font-lock-function-name-face))])
    ))

(define-derived-mode quakec-ts-mode prog-mode "QuakeC-ts"
  "Major mode for editing QuakeC files with tree-sitter."

  ;; TODO: syntax table?
  ;; :syntax-table quakec-ts-mode-syntax-table

  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'quakec)
    (treesit-parser-create 'quakec)
    (quakec-ts-setup)))

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
                (type constant keyword numeric_literal string_literal builtin_literal preprocessor)
                (function-name variable)
                (delimiter)))

  ;; indentation
  ;;

  ;; TODO:
  ;; (setq-local treesit-simple-indent-rules quakec-ts-indent-rules)

  ;; mandatory
  ;;
  (treesit-major-mode-setup))
