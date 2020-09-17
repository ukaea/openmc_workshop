#!/usr/bin/env python3

"""example_CAD_simulation.py: uses a dagmc.h5m file for the geometry."""

__author__ = "Jonathan Shimwell"

import openmc
import json
import os
from neutronics_material_maker import Material
from parametric_plasma_source import PlasmaSource, SOURCE_SAMPLING_PATH

# MATERIALS using the neutronics material maker

breeder_material = Material(material_name='Li4SiO4',
                            enrichment=90,
                            material_tag='blanket_material'
                            ).openmc_material

copper = Material(material_name="copper",
                  material_tag="copper"
                  ).openmc_material

eurofer = Material(material_name='eurofer',
                   material_tag="eurofer").openmc_material

mats = openmc.Materials([breeder_material, eurofer, copper])


# GEOMETRY using dagmc doesn't contain any CSG geometry

universe = openmc.Universe()
geom = openmc.Geometry(universe)


# SIMULATION SETTINGS

# Instantiate a Settings object
sett = openmc.Settings()
batches = 1000
sett.batches = batches
sett.inactive = 0
sett.particles = 1000
sett.run_mode = 'fixed source'
# sett.output = {'tallies': False}
sett.dagmc = True  # this is the openmc command enables use of the dagmc.h5m file as the geometry


# creates a source object
source = openmc.Source()

plasma_params = {
    "elongation": 2.9,
    "ion_density_origin": 1.09e20,
    "ion_density_peaking_factor": 1,
    "ion_density_pedestal": 1.09e20,
    "ion_density_separatrix": 3e19,
    "ion_temperature_origin": 45.9,
    "ion_temperature_peaking_factor": 8.06,
    "ion_temperature_pedestal": 6.09,
    "ion_temperature_separatrix": 0.1,
    "major_radius": 1.9*100,
    "minor_radius": 1.118*100,
    "pedestal_radius": 0.8 *  1.118*100,
    "plasma_id": 1,
    "shafranov_shift": 0.44789,
    "triangularity": 0.270,
    "ion_temperature_beta": 6,
}

plasma = PlasmaSource(**plasma_params)
# this creates a neutron distribution with the shape of a tokamak plasma


source = openmc.Source()
source.library = SOURCE_SAMPLING_PATH
source.parameters = str(plasma)
sett.source = source


tallies = openmc.Tallies()

# this loads up the tet mesh created in Trelis so that it can be used as a mesh filter
# umesh = openmc.UnstructuredMesh("tet_mesh.inp")
# umesh = openmc.UnstructuredMesh("tet_mesh.exo")
umesh = openmc.UnstructuredMesh("tet_mesh.h5m")
mesh_filter = openmc.MeshFilter(umesh)

umesh_tally = openmc.Tally(name='tally_on_umesh')
umesh_tally.filters = [mesh_filter]
umesh_tally.scores = ['heating']
umesh_tally.estimator = 'tracklength'
tallies.append(umesh_tally)


# Run OpenMC!
model = openmc.model.Model(geom, mats, sett, tallies)
# model.run()
model.run()
