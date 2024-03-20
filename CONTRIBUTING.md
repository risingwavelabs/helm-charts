# Contributing Guide

Thank you for your interest in contributing to the RisingWave Helm Charts project! We appreciate your time and effort in helping make these charts better. This document outlines the guidelines and best practices for contributing.

## Ways to Contribute

There are many ways to contribute to this project:

- **Report Bugs**: If you encounter any issues or bugs, please open a new [issue](https://github.com/risingwave/helm-charts/issues/new/choose) and provide detailed information about the problem, including steps to reproduce, expected behavior, and any relevant logs or error messages.

- **Request Features**: If you have an idea for a new feature or enhancement, please open a new [issue](https://github.com/risingwave/helm-charts/issues/new/choose) and describe your proposed change in detail.

- **Submit Pull Requests**: If you'd like to contribute code changes or documentation improvements, please follow the steps outlined below.

## Development Setup

1. Fork the [risingwavelabs/helm-charts](https://github.com/risingwavelabs/helm-charts) repository.
2. Clone your forked repository: `git clone https://github.com/YOUR_USERNAME/helm-charts.git`
3. Navigate to the project directory: `cd helm-charts`
4. Install the required dependencies (e.g., Helm, etc.).
5. Run `helm dependency update` under the chart you would like to update.

## Contribution Workflow

1. Create a new branch for your changes: `git checkout -b feat/your-feature-name`
2. Make the necessary changes and additions to the code or documentation.
3. Test your changes locally to ensure they work as expected.
4. Commit your changes with a descriptive commit message: `git commit -s -m "Add your commit message here"`
5. Push your changes to your forked repository: `git push origin feat/your-feature-name`
6. Open a new Pull Request (PR) on the [risingwavelabs/helm-charts](https://github.com/risingwavelabs/helm-charts) repository, providing a detailed description of your changes and any relevant information.

## Code Guidelines

- Follow the existing coding style and conventions used in the project.
- Write clear and concise comments to explain your code changes.
- Make sure your code changes are thoroughly tested and do not introduce new bugs or regressions.
- Write unit tests if possible. We used [helm-unittest](https://github.com/helm-unittest/helm-unittest) to run the tests.

## Documentation

- Update the relevant documentation (e.g., README, chart README files) to reflect your changes.
- Ensure that the documentation is clear, concise, and easy to understand.

## Review Process

- Your pull request will be reviewed by the project maintainers.
- Address any feedback or requested changes promptly.
- Once your changes are approved, they will be merged into the main repository.

## Code of Conduct

Please note that by participating in this project, you are expected to uphold the [Code of Conduct](https://gist.githubusercontent.com/TennyZhuang/f00be7f16996ea48effb049aa7be4d66/raw/c6e188e3cf079bf8335a8b12235ad427fd0be50b/RW_CLA).

## License

By contributing to this project, you agree that your contributions will be licensed under the [Apache 2.0 License](LICENSE).

Thank you for your contributions to the RisingWave Helm Charts project!