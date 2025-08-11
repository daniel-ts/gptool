;;; gptool.el --- High-level tools for gptel and friends -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Daniel Chertkov

;; Author: Daniel Chertkov
;; Version: 0.2
;; Keywords: tools, ai, convenience
;; Package-Requires: ((emacs "29.1") (gptel "0.9.8.5") (s "1.13.0") (dash "2.20.0"))

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your
;; option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides additional tools for `gptel`, such as
;; SQLite integration.
;;
;; See the documentation for usage details.

;;; Code:

;;;; Requirements
(add-to-list 'load-path
             (file-name-directory (or load-file-name buffer-file-name)))

(require 'gptool-project)
(require 'gptool-sqlite)

(gptel-make-tool
 :name "sqlite_query_schema"
 :function #'gptool-sqlite-query-schema
 :description "Get the SQLite schema of the database (e.g. the SQL that created
the tables and views)"
 :args nil
 :category "SQLite")

(gptel-make-tool
 :name "sqlite_query_database"
 :function #'gptool-sqlite-query-database
 :description "Make a read-only query against the SQLite database."
 :args (list '(:name "sqlite_query_statement"
                     :type string
                     :description
                     "The query string to query the SQLite database. The query
must conform to SQLite SQL, must start with either of SELECT, SHOW, DESCRIBE,
EXPLAIN, VALUES, PRAGMA; and must under no circumstances modify the database in
any way!"))
 :category "SQLite")

(gptel-make-tool
   :name "list_files_of_project"
   :function #'projectile-current-project-files
   :description "list the files by their relative path of the current project"
   :args nil
   :category "project")

(gptel-make-tool
 :name "read_project_file"
 :function #'gptool-project--read-project-file
 :description "read the contents of a file that belongs to the current project"
 :args
 (list '(:name "file_path"
               :type string
               :description
               "the relative path of the file of the project whose contents are to be retrieved"))
 :category "project")

;;;; Provide
(provide 'gptool)
