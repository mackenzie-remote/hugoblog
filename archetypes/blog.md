+++
title = "{{ replace .Name "-" " " | title }}"
date = "{{ now.Format "2006-01-02" }}"
tags = [{{ range $plural, $terms := .Site.Taxonomies }}{{ range $term, $val := $terms }}"{{ printf "%s" $term }}",{{ end }}{{ end }}]
+++

{{< custom-toc >}}
