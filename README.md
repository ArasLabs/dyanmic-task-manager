>## Archived Aras Community Project
*This project has been migrated to GitHub from the old Aras Projects page (http://www.aras.com/projects). As an Archived project, this project is no longer being actively developed or maintained.*

>*For current projects, please visit the new Aras Community Projects page on the updated Aras Community site: http://community.aras.com/projects*

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
[v1.2](https://github.com/ArasLabs/dyanmic-task-manager/releases/tag/v1.2) | Updating folder structure
[v1](https://github.com/ArasLabs/dyanmic-task-manager/releases/tag/v1) | DTM 4.0 Install Package

#### Supported Aras Versions

Project | Aras
--------|------
[v1.2](https://github.com/ArasLabs/dyanmic-task-manager/releases/tag/v1.2) | 10.0 SP1-SP3
[v1](https://github.com/ArasLabs/dyanmic-task-manager/releases/tag/v1) | 10.0 SP1-SP3

## Installation

#### Important!
**Always back up your code tree and database before applying an import package or code tree patch!**

### Pre-requisites

1. Aras Innovator installed
2. Aras Package Import tool
3. **dynamic-task-manager** import packages

### Install Steps

These steps are also available in your local `..\dynamic-task-manager\Documentation` folder

#### Code Tree Installation

1. Backup your code tree and store the archive in a safe place.
2. Copy the `Innovator` folder in your local `..\dynamic-task-manager\` folder
3. Paste this to the root of your install directory
+ By default your root directory is `C:\Program Files\Aras\Innovator`

#### Database Installation

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
9. Close the Aras Package Import tool

#### Additional Installation

1. Execute the DTM-4.0-setup.exe located in your local `..\dynamic-task-manager\` folder
2. Set the Destination Folder to to the root of your install directory
+ By default your root directory `C:\Program Files\Aras\Innovator`
3. Click Next
4. Select the Aras Database to add the Dynamic Task Manager to
5. Click Next
6. Input the Web Alias for your Aras Innovator instance
+ By default your web Alias will be `InnovatorServer`
7. Input the ID and Password of the admin user
8. Input the desired web alias of the Dynamic Task Manager
+ By default this will be set to `DTMServer`
9. Click Next
10. Select the desired destination folder to install DTM to
+ By default this will be the same as the Aras Innovator installation path
11. Set up the DTM application in IIS
	1. Launch IIS
	2. Expand the Connections window until you reach Default Web Site
	3. Right click on Default Web Site and select "Add Application..."
		* Name: Input DTM Web Alias (e.g. DTMServer)
		* Application program pool: ASP.NET v4.0
		* Path: Input DTM installation path: (e.g. `C:\Program Files\Aras\Innovator\DTM`)
    4. Click OK

#### DTM License Key Request & Set-up
1. Create DTM License Key Request File
	1. Execute DTMLicenseKeyRequest.exe
	2. Input your Company Name
	3. Select an option
	4. Click Create
2. Email the resulting dtm_license.lic to sales-j@zionex.com to request a DTM License Key
3. After receiving the License Code, copy the dtm_license.lic file to your installation folder

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
