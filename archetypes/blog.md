---
title: "{{ replace (replaceRE `^\d{4}-\d{2}-\d{2}-` `` .File.ContentBaseName) `-` ` ` | title }}"
date: "{{ with findRE `^\d{4}-\d{2}-\d{2}` .File.ContentBaseName 1 }}{{ index . 0 }}{{ else }}{{ now.Format "2006-01-02" }}{{ end }}"
author: "Joshua Steele"
description: >-
  TODO: Add a brief summary for listings and meta tags.
tags: []
cover: ""
caption: ""
pdf: ""
slug: "{{ .File.ContentBaseName }}"
draft: true
---
