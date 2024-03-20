Plugin for RisingWave Helm Chart
---

Install the [risingwave](/plugins/risingwave) plugin to operate the releases.

```bash
helm plugin install ./plugins/risingwave
```

Pause the release:

```bash
helm risingwave pause <release-name> [chart]
```

Resume the release:

```bash
helm risingwave resume <release-name> [chart]
```

Upgrade the release:

```bash
helm risingwave upgrade <release-name> [chart] --version=<version>
```

Rollback the upgrade:

```bash
helm risingwave rollback <release-name> [chart]
```
