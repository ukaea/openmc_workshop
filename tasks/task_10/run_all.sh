

# rm -r  manifest_processed
# Use the geomPipeline.py script from PPP to make the brep file
# PPP is avaialbe here https://github.com/ukaea/parallel-preprocessor
# geomPipeline.py manifest.json

rm dagmc_notwatertight.h5m
# -t is the mesh tolerance
occ_faceter manifest_processed/manifest_processed.brep -t 0.0001 -o dagmc_notwatertight.h5m

rm dagmc.h5m
make_watertight dagmc_notwatertight.h5m -o dagmc.h5m

# optional stl for visualization
mbconvert dagmc.h5m dagmc.stl

# optional vtk for visualization
mbconvert dagmc.h5m dagmc.vtk

python3 example_CAD_simulation.py
