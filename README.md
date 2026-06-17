# SSM
 -------------------------------------------------------------------------
           ____   ____   __  __ 
          / ___| / ___| |  \/  |
          \___ \ \___ \ | |\/| |   Single-Subject Morphometry Tool, v1.1
           ___) | ___) || |  | |
          |____/ |____/ |_|  |_|
  -------------------------------------------------------------------------
  University of Campinas, Neuroimaging Laboratory
 
***SSM (Single-Subject Morphometry)*** is an open-source framework for individualized assessment of brain structural abnormalities using MRI. The software generates subject-specific maps of white and gray matter alterations based on normative models derived from healthy controls, enabling the detection and quantification of morphometric abnormalities at the voxel level.

**SSM** supports the evaluation of atrophy, hypertrophy, and focal cortical dysplasia (FCD) recquiring only a high-quality T1-weighted MRI scan (FLAIR image optional). Demographic variables such as age and sex can be incorporated to improve model accuracy but are not required.

The framework features a fully integrated graphical user interface (GUI), providing an accessible workflow without the need for programming expertise. SSM supports both single-subject analyses and automated batch processing of large datasets. Brain tissue metrics are extracted using the [CAT12](https://neuro-jena.github.io/cat/) toolbox, while all harmonization and statistical mapping procedures are implemented within the SSM framework.

Key Features 

**Advanced Site Harmonization**: Embedded with SSM_combat to eliminate scanner and sequence biases (e.g., T1w vs. FLAIR) using single-subject projection algebra.
**Biological Confounder Control**: Automatic regression for Age, Gender, and Total Intracranial Volume (TIV).
**Fast Non-Parametric Inference**: Cluster-based permutation testing with an intelligent caching system for empirical thresholds.
**Outlier & Quality Control**: Automated IQR-based outlier detection routines to protect the normative database from structural noise.

Before running SSM, ensure you have the following dependencies installed and configured in your MATLAB environment (Third-Party Prerequisites for **SSM**):
 - Statistical Parametric Mapping ([SPM](https://www.fil.ion.ucl.ac.uk/spm/))
 - Computational Anatomy Toolbox ([CAT12](https://neuro-jena.github.io/cat/))
 - [ComBat](https://github.com/Jfortin1/ComBatHarmonization/tree/master) Multi-Site Harmonization Tool (Adapted version for SSM **included with SSM code**)

<p align="center">
  <img width="400" height="600" alt="SSM graphical user interface (GUI)" src="https://github.com/user-attachments/assets/f626fa54-33e4-44ad-90cf-dff1c7fd2f2c" />
  <br>
  <em><b>Figure 1:</b> SSM graphical user interface (GUI).</em>
</p>

<p align="center">
  <img width="1200" height="500" alt="Example resut for focal cortical dysplasia (blue maps: drawn ROI; hot-scaled map: SSM result)" src="https://github.com/user-attachments/assets/ff6d6254-de1f-4cc4-8153-b31c44873a61" />
  <br>
  <em><b>Figure 2:</b> Example resut for focal cortical dysplasia (blue maps: drawn ROI; hot-scaled map: SSM FCD result).</em>
</p>

<p align="center">
  <img width="1344" height="570" alt="Example resut for Grey Matter Atrophy Study on patient with left mesia temporal lobe epilepsy (hot-scaled map: SSM individual atrophy map)" src="https://github.com/user-attachments/assets/345c3d9f-7292-4230-a3a9-115a0c2a9e19" />
  <br>
  <em><b>Figure 3:</b> Example resut for Grey Matter Atrophy Study on patient with left mesial temporal lobe epilepsy (hot-scaled map: SSM individual atrophy map).</em>
</p>



