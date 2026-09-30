def complete_docker_containers [] {
    ^docker ps --format "{{.Names}}" | lines
}

export def dlog --wrapped [
    container: string@complete_docker_containers
    --json (-j)
    ...args
] {
    let language = if $json { "json" } else { "log" }

    ^docker logs ...$args $container o+e>| ^bat --paging=never --style=plain --language $language
}
