;;; gptool-sqlite.el --- SQLite integration as a gptel tool -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Daniel Chertkov

;; Author: Daniel Chertkov
;; Version: 0.1
;; Keywords: gptel, MCP, tools, AI, sqlite
;; Package-Requires: ((emacs "29.1") (dash "2.20.0") (s "1.13.0") (gptel " v0.9.8.5"))

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides gptel tools for interacting with SQLite databases.
;; It allows SELECT-like queries and schema introspection via gptel.
;;
;; Dependencies: Requires Emacs 29 (for sqlite3), dash, s, and gptel.
;;
;; See the code for usage details.

;;; Code:
(require 'dash)
(require 's)
(require 'gptel)

(defvar gptool-sqlite--error-msg-plist
  '(:sqlite-unsupported
    "SQLite is not supported by the current Emacs session."
    :no-db-chosen
    "No SQLite database was chosen by the user."
    :db-unreadable
    "The file under the user's chosen path is unreadable."
    :not-a-sqlite-db
    "The file the user chose is not a SQLite database."
    :not-a-select-stmt
    "The query does not start with a SELECT statement.")
  "Error messages plist that contains all error messages that are fed to
the LLM when something goes wrong.")

(defvar gptool-sqlite--db nil
  "Reference to the SQLite database that is used by gptel as a tool.")

(defun gptool-sqlite--ask-db-path ()
  (condition-case nil
      (read-file-name "Select an SQLite DB file: "
                      default-directory nil t)
    (quit ; catch a quit
     nil)))

(defun gptool-sqlite--get-db ()
  "When gptool-sqlite--db is nil, it opens the SQLite database found under the
`gptool-sqlite--gptel-tool-sqlite-db-env-var' environment variable. The
env var must point an existing and readable file. Otherwise nothing
happens."

  (unless (sqlite-available-p)
    (error (plist-get gptool-sqlite--error-msg-plist :sqlite-unsupported)))

  (unless (sqlitep gptool-sqlite--db)
    (setq gptool-sqlite--db nil))

  (if (null gptool-sqlite--db)
      ;; no open SQLite database referenced
      (let ((path (gptool-sqlite--ask-db-path)))

        ;; check choice: nil -> user aborted choice
        (when (null path)
          (error (plist-get gptool-sqlite--error-msg-plist :no-db-chosen)))

        ;; check readability
        (unless (file-readable-p path)
          (error (plist-get gptool-sqlite--error-msg-plist :db-unreadable)))

        ;; set the database and return it
        (setq gptool-sqlite--db (sqlite-open path)))

    ;; there is an open SQLite database, do not open a new one
    ;; return the existing instead
    gptool-sqlite--db))

(defun gptool-sqlite--readonly-query-p (query)
  "Return non-nil if QUERY appears to be a read-only SQL statement.
This is a heuristic and not 100% reliable."

  (unless (stringp query)
    (error "the query must be a string"))

  (thread-last query
               ;; remove c-comments like /* my comment */
               (replace-regexp-in-string "/\\*.*?\\*/" "")
               ;; remove -- to end of line comments
               (replace-regexp-in-string "--.*$" "")
               ;; trim whitespace
               s-trim
               ;; extract the statement: first word and upcase
               (s-split " ") car upcase

               ;; match against a list of safe statements
               (-contains? '("SELECT" "SHOW" "DESCRIBE" "EXPLAIN" "VALUES"
                             "PRAGMA"))))

(defun gptool-sqlite-unset-db-path ()
  (interactive)
  (setq gptool-sqlite--db nil))

(defun gptool-sqlite-query-schema ()
  "Return the SQL create table statements from the SQLite database to give
the LLM an overview of the schema."
  (thread-last
    "SELECT sql FROM sqlite_master WHERE type='table' OR type='view'"
    (sqlite-select (gptool-sqlite--get-db))
    (-map #'car)
    (s-join "\n")))

(defun gptool-sqlite-query-database (query)
  "Allow the LLM to query the database."

  (unless (gptool-sqlite--readonly-query-p query)
    (error (plist-get gptool-sqlite--error-msg-plist :not-a-select-stmt)))

  (sqlite-select (gptool-sqlite--get-db) query))

(provide 'gptool-sqlite)

;;; gptool-sqlite.el ends here
