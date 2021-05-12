0
"""
tests the create_isotope_plot from plotting_utils in the same way the examples
use the function.
"""

import os
import sys
import unittest
from pathlib import Path

import nbformat
from nbconvert.preprocessors import ExecutePreprocessor
from nbconvert.preprocessors.execute import CellExecutionError
from nbformat.validator import NotebookValidationError


def _notebook_run(path):
    """
    Execute a notebook via nbconvert and collect output.
    :returns (parsed nb object, execution errors)
    """
    kernel_name = 'python%d' % sys.version_info[0]
    this_file_directory = os.path.dirname(__file__)
    errors = []

    with open(path) as f:
        nb = nbformat.read(f, as_version=4)
        nb.metadata.get('kernelspec', {})['name'] = kernel_name
        ep = ExecutePreprocessor(kernel_name=kernel_name, timeout=300) #, allow_errors=True

        try:
            ep.preprocess(nb, {'metadata': {'path': this_file_directory}})

        except CellExecutionError as e: 
            if "SKIP" in e.traceback:
                print(str(e.traceback).split("\n")[-2])
            else:
                raise e

    return nb, errors


cwd = os.getcwd()


class test_tasks(unittest.TestCase):


    def test_task_1(self):
        for notebook in Path().rglob("tasks/tasks/task_01_*/*.ipynb"):
            print(notebook)
            nb, errors = _notebook_run(notebook)
            assert errors == []

    def test_task_2(self):
        for notebook in Path().rglob("tasks/task_02_*/*.ipynb"):
            print(notebook)
            nb, errors = _notebook_run(notebook)
            assert errors == []

    def test_task_3(self):
        for notebook in Path().rglob("tasks/task_03_*/*.ipynb"):
            print(notebook)
            nb, errors = _notebook_run(notebook)
            assert errors == []


    # ModuleNotFoundError: No module named 'source_extraction_utils
    # or fails to find initial_source.h5 file
    # also tried adding this to the Notebook
    # import sys  
    # sys.path.insert(0, '/home/jshim/openmc_workshop/tasks/task_04_make_sources/')
    # def test_task_4(self):
    #     os.chdir('tasks/task_04_make_sources/')
    #     for notebook in Path().rglob("*.ipynb"):
    #         print(notebook)
    #         nb, errors = _notebook_run(notebook)
    #         assert errors == []

    def test_task_5(self):
        os.chdir(cwd)
        os.chdir('tasks/task_05_CSG_cell_tally_TBR/')
        for notebook in Path().rglob("*.ipynb"):
            print(notebook)
            nb, errors = _notebook_run(notebook)
            assert errors == []

    def test_task_6(self):
        os.chdir(cwd)
        os.chdir('tasks/task_06_CSG_cell_tally_DPA/')
        for notebook in Path().rglob("*.ipynb"):
            print(notebook)
            nb, errors = _notebook_run(notebook)
            assert errors == []

    # ModuleNotFoundError: No module named 'plotting_utils'
    # def test_task_7(self):
    #     os.chdir(cwd)
    #     os.chdir('tasks/task_07_CSG_cell_tally_spectra/')
    #     for notebook in Path().rglob("*.ipynb"):
    #         print(notebook)
    #         nb, errors = _notebook_run(notebook)
    #         assert errors == []

# ModuleNotFoundError: No module named 'statepoint_to_vtk'
    # def test_task_8(self):
    #     os.chdir(cwd)
    #     os.chdir('tasks/task_08_CSG_mesh_tally/')
    #     for notebook in Path().rglob("*.ipynb"):
    #         print(notebook)
    #         nb, errors = _notebook_run(notebook)
    #         assert errors == []

    def test_task_9(self):
        os.chdir(cwd)
        os.chdir('tasks/task_09_CSG_surface_tally_dose/')
        for notebook in Path().rglob("*.ipynb"):
            print(notebook)
            nb, errors = _notebook_run(notebook)
            assert errors == []

#  'Compound' object has no attribute 'val'
    # def test_task_10(self):
    #     os.chdir(cwd)
    #     os.chdir('tasks/task_10_making_CAD_geometry/')
    #     for notebook in Path().rglob("*.ipynb"):
    #         print(notebook)
    #         nb, errors = _notebook_run(notebook)
    #         assert errors == []

# AttributeError: 'Compound' object has no attribute 'val'
    # def test_task_11(self):
    #     os.chdir(cwd)
    #     os.chdir('tasks/task_11_CAD_cell_tally_heat/')
    #     for notebook in Path().rglob("*.ipynb"):
    #         print(notebook)
    #         nb, errors = _notebook_run(notebook)
    #         assert errors == []

# AttributeError: 'Compound' object has no attribute 'val'
    # def test_task_12(self):
    #     os.chdir(cwd)
    #     os.chdir('tasks/task_12_CAD_mesh_fast_flux/')
    #     for notebook in Path().rglob("*.ipynb"):
    #         print(notebook)
    #         nb, errors = _notebook_run(notebook)
    #         assert errors == []

# # ModuleNotFoundError: No module named 'statepoint_to_vtk'
#     def test_task_13(self):
#         os.chdir(cwd)
#         os.chdir('tasks/task_13_parameter_study_sampling/')
#         for notebook in Path().rglob("*.ipynb"):
#             print(notebook)
#             nb, errors = _notebook_run(notebook)
#             assert errors == []

# ModuleNotFoundError: No module named 'statepoint_to_vtk'
    # def test_task_14(self):
    #     os.chdir(cwd)
    #     os.chdir('tasks/task_14_parameter_study_optimisation//')
    #     for notebook in Path().rglob("*.ipynb"):
    #         print(notebook)
    #         nb, errors = _notebook_run(notebook)
    #         assert errors == []
