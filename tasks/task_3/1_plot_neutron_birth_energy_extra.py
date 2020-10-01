#!/usr/bin/env python3

"""1_example_neutron_spectra_tokamak.py: plots neutron spectra."""

import openmc
import numpy as np
import plotly.graph_objects as go

def get_neutron_spectrum_from_plasma(plasma_temperature=14080000.0):

    # MATERIALS (there are none in this model)

    mats = openmc.Materials([])


    # GEOMETRY

    # surfaces
    inner_surface = openmc.Sphere(r=100)
    outer_surface = openmc.Sphere(r=101, boundary_type='vacuum')

    # cells
    inner_cell = openmc.Cell(region=-inner_surface)
    # this is filled with a void / vauum by default

    outer_cell = openmc.Cell(region=+inner_surface & -outer_surface)
    # this is filled with a void / vauum by default

    universe = openmc.Universe(cells=[inner_cell, outer_cell])
    geom = openmc.Geometry(universe)


    # SIMULATION SETTINGS

    # Instantiate a Settings object
    sett = openmc.Settings()
    sett.batches = 20
    sett.inactive = 0 # the default is 10, which would be wasted computing for us
    sett.particles = 500000
    sett.run_mode = 'fixed source'

    # Create a DT point source
    source = openmc.Source()
    source.space = openmc.stats.Point((0, 0, 0))
    source.angle = openmc.stats.Isotropic()
    source.energy = openmc.stats.Muir(kt=plasma_temperature)
    sett.source = source

    # setup the  filters for the tallies
    neutron_particle_filter = openmc.ParticleFilter(['neutron'])
    surface_filter = openmc.SurfaceFilter(inner_surface) # detects particles across a surface
    
    energy_filter = openmc.EnergyFilter(energy_bins)
    spectra_tally = openmc.Tally(name='energy_spectra')
    spectra_tally.scores = ['current']
    spectra_tally.filters = [surface_filter, neutron_particle_filter, energy_filter]

    tallies = openmc.Tallies()
    tallies.append(spectra_tally)


    # combine all the required parts to make a model
    model = openmc.model.Model(geom, mats, sett, tallies)
    # Run OpenMC!
    results_filename = model.run()

    # open the results file
    results = openmc.StatePoint(results_filename)

    #extracts the tally values from the simulation results
    surface_tally = results.get_tally(name='energy_spectra')
    surface_tally = surface_tally.get_pandas_dataframe()
    surface_tally_values = surface_tally['mean']

    return surface_tally_values




energy_bins = np.linspace(5, 25e6, 500)

# this section plots the results
fig = go.Figure()

for temperature in np.linspace(10e3, 20e3, 3):

    surface_tally_values = get_neutron_spectrum_from_plasma(plasma_temperature=temperature)

    fig.add_trace(go.Scatter(x=energy_bins,
                            y=surface_tally_values,
                            name=str(temperature)+' eV',
                            # line=dict(shape='hv')
                            )
                )

fig.update_layout(title='Neutron energy spectra from different temperature plasma sources',
                  xaxis={'title': 'Energy (eV)',
                         'type': 'linear'},
                  yaxis={'title': 'Neutrons per cm2 per source neutron',
                         'type': 'linear'}
                 )

fig.update_layout(
    updatemenus=[
        go.layout.Updatemenu(
            buttons=list([
                dict(
                    args=[{"xaxis.type": 'lin', "yaxis.type": 'lin', 'yaxis.range': (1e6, 14.1e6)}],
                    label="linear(x) , linear(y)",
                    method="relayout"
                ),
                dict(
                    args=[{"xaxis.type": 'log', "yaxis.type": 'log'}],
                    label="log(x) , log(y)",
                    method="relayout"
                ),
                dict(
                    args=[{"xaxis.type": 'log', "yaxis.type": 'lin', 'yaxis.range': (1e6, 14.1e6)}],
                    label="log(x) , linear(y)",
                    method="relayout"
                ),
                dict(
                    args=[{"xaxis.type": 'lin', "yaxis.type": 'log'}],
                    label="linear(x) , log(y)",
                    method="relayout"
                )
            ]),
            pad={"r": 10, "t": 10},
            showactive=True,
            x=0.5,
            xanchor="left",
            y=1.1,
            yanchor="top"
        ),
    ]
)

fig.write_html("neutron_spectra.html")
try:
    fig.write_html("/my_openmc_workshop/neutron_spectra.html")
except (FileNotFoundError, NotADirectoryError):  # for both inside and outside docker container
    pass

fig.show()
