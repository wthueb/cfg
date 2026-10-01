export def --wrapped ps [...args]: [nothing -> table] {
    let proc = if ('/bin/ps' | path exists) { '/bin/ps' } else { 'ps' }

    run-external $proc ...$args | ^jc --ps | from json
}
