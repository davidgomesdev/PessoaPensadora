#!/bin/bash

gh workflow run release.yml --ref $(git branch --show-current) \
  -f release-track=internal \
  -f skip-mobile-deploy=false \
  -f "whats-new=Nova versão com melhorias funcionais." \
  && sleep 5 \
  && gh run watch $(gh run list --workflow=release.yml --limit=1 --json databaseId -q '.[0].databaseId') \
  && tput bell
