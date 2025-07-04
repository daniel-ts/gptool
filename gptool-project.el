;;; gptool-project.el --- Access to project files as a gptel tool -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Daniel Chertkov

;; Author: Daniel Chertkov
;; Version: 0.1
;; Keywords: gptel, MCP, tools, AI, project
;; Package-Requires: ((emacs "29.1") (projectile "2.9") (gptel "0.9.8.5"))

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

;; This package provides functions for gptel tools for interacting with the
;; files of the project.  It allows SELECT-like queries and schema introspection
;; via gptel.
;;
;; Dependencies: Requires Emacs 29, projectile and gptel.
;;
;;; Code:
(require 'projectile)

(defun gptool-project--read-project-file (file_path)
  "Interface function for gptel-make-tool to allow an LLM read a file of
the project."
  (let ((path (expand-file-name file_path (or (projectile-project-root)
                                              default-directory))))

    (unless (file-readable-p path)
      (error "error: %s either does not exist or is unreadable" path))

    (with-temp-buffer
      (insert-file-contents path)
      (buffer-string))))

(provide 'gptool-project)
;;; gptool-project.el ends here
