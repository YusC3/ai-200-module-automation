# AI-200 Azure Command Scripts

A compiled collection of Azure CLI (`.ps1`) scripts organized by learning path and module exercise. These scripts are intended for automation or as a study aid for the [**AI-200 certification**](https://learn.microsoft.com/en-us/training/courses/ai-200t00) and general review.

---

## How to Use

For simplicity, all `.ps1` scripts are titled after the module number for the accompanied learning path.

1. Extract the repo zip file to a local folder.
2. Drop the desired `.ps1` script directly into that extracted folder.
3. Run your script **after** `azdeploy.ps1` has been executed.

---

## Folder Structure

Each folder corresponds to a Microsoft Learn learning path, named after the path's URL slug. Inside each folder, `.ps1` scripts are placed directly within their corresponding module subfolder alongside the existing exercise content.

```
2_deploy-manage-apps-azure-container-apps/
├── 1_aca-deploy-python/
│   ├── api/
│   └── module1.ps1
├── 2_aca-manage-python/
│   ├── api/
│   └── module2.ps1
└── 3_aca-scale-python/
    ├── api/
    ├── client/
    └── module3.ps1
```

To find the script for a given exercise, navigate to the learning path folder and open the corresponding module subfolder.

> **Note:** Scripts use `Set-PSDebug -Trace 1` for logging instead of `Write-Host`.

---

## Setup & Cleanup Scripts

Two utility scripts are available that work across **all** module exercises:

- **`setup.ps1`** — An ongoing amalgamation of all necessary Azure providers required to run every exercise. Run this once before starting.
- **`cleanup.ps1`** — Targets the resource group created during setup. Deleting the resource group will remove all associated resources created throughout the exercises.

---

## Who Is This For?

- Anyone studying for the **AI-200 certification**
- Those looking to **automate** exercise deployments
- Learners who want a quick reference or general review of Azure CLI commands

---

## Questions or Issues?

For any additional comments or concerns, please **open a GitHub Issue**. Happy learning! 🎓