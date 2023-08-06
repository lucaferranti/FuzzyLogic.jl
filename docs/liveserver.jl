import Pkg

Pkg.activate(@__DIR__)

using LiveServer

servedocs(; literate_dir = joinpath("docs", "src", "literate"),
          skip_dirs = [
              joinpath("docs", "src", "notebooks"),
              joinpath("docs", "src", "tutorials"),
              joinpath("docs", "src", "applications"),
          ],
          skip_files = [
              joinpath("docs", "src", "api", "logical.md"),
              joinpath("docs", "src", "api", "memberships.md"),
              joinpath("docs", "src", "assets", "indigo.css"),
          ],
          launch_browser = true,
          verbose = true)
