set(src
  docker.c
  cgroup_v1.c
  )

FLB_PLUGIN(in_docker2 "${src}" "")
