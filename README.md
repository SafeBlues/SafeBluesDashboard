# SafeBluesDashboard
`SafeBluesDashboard` is an interactive dashboard for the [Safe Blues](https://safeblues.org)
campus experiment at the University of Auckland City Campus. This experiment involved the
simulation of several simultaneous real-world epidemics by spreading safe virtual
virus-like tokens (or strands) between participating smartphones. The resulting statistics
on the transmission of these virtual viruses throughout the experiment's duration are
available through this dashboard.

## Developing
If you want to develop or customise this dashboard, then you can configure a locally hosted
instance. First, you will need to `git clone` this repository and download a copy of the
experimental dataset. Then, from within the root directory of `SafeBluesDashboard`, run
```
julia --project -E "import Pkg; Pkg.instantiate()"
```
to instantiate the environment. You should now be able to run the dashboard with
```
julia --project src/SafeBluesDashboard.jl path/to/data
```
where `path/to/data` is replaced by an absolute path to the dataset. Your locally hosted
instance is available at `127.0.0.1:8050`.
