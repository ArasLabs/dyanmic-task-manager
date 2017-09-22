# Dynamic Task Manager

DTM is an Innovator-based project management solution that provides interactive Gantt Chart UI and allows users to intuitively manage the progress of project tasks, deliverables, issues, to-do lists, related approval workflows, and furthermore visualize the allocated resource load.

Using the DTM, project manager can easily create and plan a project with the consideration of key milestones and available resources. At each location, the team members can conduct the assigned tasks by checking to-do list, register required deliverables, post issues, and check timely progress of other colleagues. A large project can be easily managed in main and sub projects so as to keep the permissions and security separately for project levels.

If you want to evaluate DTM, please download the installer, follow the installation guide to install, and send the MAC address of the server via email ( Sales-J@zionex.com ). We will send you the trial license key and the users’ manual.

Main features

–	Project WBS editing using the interactive Gantt Chart （activity add, schedule change, resources assignment, etc.）

–	Create a project from a template that has deliverables, related documents, related workflows, etc.

–	Set the project scheduling logic (Option)

–	Define a hierarchical project with sub projects

–	Resource load graph within a project or for selected projects

## History

This project and the following release notes have been migrated from the old Aras Projects page. 

Release | Notes
--------|--------
[v1](https://github.com/ArasLabs/dyanmic-task-manager/releases/tag/v1) | DTM 4.0 Install Package

#### Supported Aras Versions

Project | Aras
--------|------
[v1](https://github.com/ArasLabs/dyanmic-task-manager/releases/tag/v1) | 10.0 SP1-SP3

## Installation

#### Important!
**Always back up your code tree and database before applying an import package or code tree patch!**

### Pre-requisites

1. Aras Innovator installed
2. Aras Package Import tool
3. **dynamic-task-manager** import packages

### Install Steps

1. Backup your database and store the BAK file in a safe place.
2. Open up the Aras Package Import tool.
3. Enter your login credentials and click **Login**
  * _Note: You must login as root for the package import to succeed!_
4. Enter the package name in the TargetRelease field.
  * Optional: Enter a description in the Description field.
5. Enter the path to your local `..\dynamic-task-manager\Import\imports.mf` file in the Manifest File field.
6. Select all packages in the Available for Import field.
7. Select Type = **Merge** and Mode = **Thorough Mode**.
8. Click **Import** in the top left corner.
9. Close the Aras Package Import tool.
10. Follow the remaining instructions outlined in `..\dynamic-task-manager\Documentation\DTM_Installation_Guide_v1.0`

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

For more information on contributing to this project, another Aras Labs project, or any Aras Community project, shoot us an email at araslabs@aras.com.

## Credits

Created by Zionex.

## License

Aras Labs projects are published to Github under the MIT license. See the [LICENSE file](./LICENSE) for license rights and limitations.
