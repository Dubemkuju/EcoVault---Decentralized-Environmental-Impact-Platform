# EcoVault - Decentralized Environmental Impact Platform

A comprehensive blockchain-based sustainability platform built on Stacks that tracks carbon footprints, rewards eco-friendly actions, facilitates green project collaboration, and builds accountable environmental communities through tokenized incentives.

## Overview

EcoVault transforms environmental responsibility into a measurable, rewarding digital ecosystem where:
- **Environmental actions are tracked** with quantified carbon impact measurements
- **Carbon footprints are monitored** through comprehensive emission tracking and offset calculations
- **Green projects mobilize communities** for collective environmental impact
- **Peer verification ensures** authenticity of sustainability claims
- **Token rewards incentivize** meaningful environmental behavior change

## Key Features

### Environmental Action Tracking
- Comprehensive action type registry with carbon impact quantification
- Multi-category support: Transport, Energy, Waste, Conservation
- Measurement units and difficulty levels for accurate impact assessment
- Photo evidence support with IPFS hash integration
- Location-based action logging for geographic impact analysis

### User Environmental Profiles
- Progressive eco-level system (1-10) based on sustained environmental engagement
- Comprehensive impact metrics: carbon saved, trees planted, recycling amounts
- Reputation scoring system with peer verification integration
- Activity streaks to encourage consistent environmental behavior
- Achievement tracking for long-term motivation

### Carbon Footprint Management
- Monthly carbon footprint tracking across all emission categories
- Transport, energy, and waste emission monitoring
- Offset action integration for net footprint calculation
- Historical comparison and improvement percentage tracking
- Automated carbon credit allocation for verified offsets

### Green Project Collaboration
- Community-driven environmental project creation and management
- Target-based participation with role assignments (participant, volunteer, coordinator)
- Carbon goal tracking with real-time progress monitoring
- Duration-based project lifecycles with automatic status management
- Location-specific projects for regional environmental impact

### Peer Verification System
- Community-based action verification with confidence scoring
- Reputation-gated verifier participation (minimum 200 reputation score)
- Evidence-based verification with detailed notes and documentation
- Confidence threshold system (70%+ for approval)
- Verifier rewards to incentivize quality assurance participation

## EcoVault Carbon Credit Token (ECT)

### Token Economics
- **Symbol**: ECT
- **Decimals**: 6
- **Max Supply**: 8,000,000 ECT
- **Distribution**: Merit-based rewards for verified environmental actions

### Reward Structure
- **Carbon Offset Actions**: 100 ECT
- **Renewable Energy Usage**: 150 ECT
- **Tree Planting**: 80 ECT
- **Recycling Activities**: 40 ECT
- **Action Verification**: 50 ECT
- **Carbon Footprint Tracking**: 20 ECT

## Technical Architecture

### Smart Contract Functions

#### Environmental Action Management
- `add-action-type`: Define new environmental action categories with carbon impact specifications
- `log-eco-action`: Record environmental actions with quantity, location, and evidence
- `verify-eco-action`: Community verification system with confidence scoring and evidence review

#### Carbon Footprint Tracking
- `update-carbon-footprint`: Monthly emission tracking across transport, energy, and waste categories
- Automatic net footprint calculation with offset integration
- Historical tracking for improvement measurement and trend analysis

#### Green Project Coordination
- `create-green-project`: Launch community environmental projects with carbon goals
- `join-green-project`: Participate in projects with role-based contribution tracking
- Real-time participant and carbon goal progress monitoring

#### Profile and Token Management
- `transfer`: Peer-to-peer ECT token transfers with memo support
- `update-username`: Personalize environmental identity and community presence
- Comprehensive read-only functions for data access and transparency

### Advanced Data Structures

#### Environmental Action Type
```clarity
{
  name: (string-ascii 64),
  category: (string-ascii 32),
  carbon-impact-kg: uint,
  measurement-unit: (string-ascii 16),
  difficulty-level: uint,
  verified: bool
}
```

#### User Environmental Profile
```clarity
{
  username: (string-ascii 32),
  eco-level: uint,
  total-actions: uint,
  carbon-saved-kg: uint,
  trees-planted: uint,
  recycling-kg: uint,
  renewable-energy-kwh: uint,
  current-streak: uint,
  reputation-score: uint,
  last-activity: uint
}
```

#### Green Project Structure
```clarity
{
  creator: principal,
  title: (string-ascii 128),
  description: (string-ascii 500),
  project-type: (string-ascii 32),
  target-participants: uint,
  carbon-goal-kg: uint,
  current-carbon-kg: uint,
  start-date: uint,
  end-date: uint,
  location: (string-ascii 64),
  active: bool
}
```

#### Carbon Footprint Tracking
```clarity
{
  transport-emissions-kg: uint,
  energy-emissions-kg: uint,
  waste-emissions-kg: uint,
  total-emissions-kg: uint,
  offset-actions-kg: uint,
  net-footprint-kg: uint,
  improvement-percent: uint
}
```

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) development environment
- Stacks wallet for blockchain interactions
- Understanding of carbon footprint terminology and environmental impact measurement

### Installation
```bash
# Clone the repository
git clone https://github.com/your-org/ecovault-platform
cd ecovault-platform

# Install dependencies
clarinet install

# Run comprehensive tests
clarinet test

# Deploy to testnet
clarinet deploy --testnet
```

### Usage Examples

#### Add Environmental Action Type
```clarity
(contract-call? .ecovault add-action-type 
  "Bike to work instead of driving" 
  "transport" 
  u5000  ;; 5kg CO2 saved per trip
  "km" 
  u2)
```

#### Log Environmental Action
```clarity
(contract-call? .ecovault log-eco-action
  u1
  u10  ;; 10km biked
  "Downtown to Office"
  "Daily commute by bicycle"
  none)
```

#### Create Green Project
```clarity
(contract-call? .ecovault create-green-project
  "Community Tree Planting Initiative"
  "Monthly tree planting in local parks to improve air quality"
  "reforestation"
  u20
  u50000  ;; 50,000kg CO2 offset goal
  u30     ;; 30 days
  "Central Park Area")
```

#### Update Carbon Footprint
```clarity
(contract-call? .ecovault update-carbon-footprint
  u150   ;; transport emissions
  u300   ;; energy emissions
  u50    ;; waste emissions
  u100)  ;; offset actions
```

#### Verify Environmental Action
```clarity
(contract-call? .ecovault verify-eco-action
  u1
  u85    ;; 85% confidence
  "Verified through photo evidence and location data")
```

## Platform Features

### Environmental Impact Quantification
- Science-based carbon impact calculations for all action types
- Standardized measurement units for consistent impact assessment
- Difficulty-based action categorization for skill-appropriate challenges
- Cumulative impact tracking across all environmental categories

### Community-Driven Quality Assurance
- Peer verification system with reputation-based gating
- Evidence-based verification with photo support and detailed documentation
- Confidence scoring system for verification quality assessment
- Community consensus mechanism for disputed verifications

### Gamification and Motivation
- Progressive eco-level advancement through sustained environmental engagement
- Activity streak tracking to encourage consistent behavior
- Reputation system with peer validation and community recognition
- Achievement milestones with token rewards for major environmental impact

### Project-Based Collaboration
- Community-driven environmental project creation and coordination
- Role-based participation with contribution tracking and recognition
- Target-based goals with real-time progress monitoring
- Geographic organization for local environmental impact initiatives

## Security and Trust Features

- **Reputation-based verification**: Minimum reputation requirements prevent spam and ensure quality
- **Multi-factor validation**: Location, photo evidence, and peer verification create comprehensive validation
- **Supply cap protection**: Token minting limits prevent inflation while rewarding genuine environmental action
- **Time-based tracking**: Activity streaks and timestamps prevent gaming and encourage sustained behavior

## Use Cases

### For Individual Environmental Enthusiasts
- Track personal carbon footprint with detailed emission category breakdowns
- Earn rewards for verified environmental actions and sustained behavior
- Participate in community environmental projects with measurable impact
- Build environmental reputation through peer verification and community engagement

### For Environmental Organizations
- Create and coordinate large-scale environmental projects with community participation
- Access verified environmental impact data for reporting and grant applications
- Engage communities through token-based incentive programs
- Build transparent, accountable environmental action networks

### For Businesses and Corporations
- Implement employee environmental incentive programs with measurable outcomes
- Access verified carbon offset data for sustainability reporting
- Support community environmental projects with transparent impact tracking
- Integrate with existing corporate sustainability and ESG initiatives

### For Researchers and Policymakers
- Access anonymized, verified environmental behavior data for research
- Track regional environmental action trends and effectiveness
- Evaluate policy impact through behavioral change measurement
- Study community-driven environmental initiative success factors

## Advanced Features

### Carbon Credit Integration
- Verified environmental actions generate tokenized carbon credits
- Peer verification ensures authenticity and prevents double-counting
- Integration with existing carbon credit markets and standards
- Transparent, blockchain-based carbon credit provenance tracking

### Community Governance
- Reputation-based participation in platform governance decisions
- Community validation of new action types and carbon impact calculations
- Democratic project approval and funding allocation mechanisms
- Transparent dispute resolution for verification conflicts

### Data Analytics and Insights
- Personal environmental impact dashboards with trend analysis
- Community environmental impact visualization and reporting
- Project effectiveness measurement and optimization recommendations
- Behavioral change analysis and intervention effectiveness studies

## Future Development Roadmap

### Phase 1: Enhanced Verification
- IoT device integration for automated environmental action verification
- Machine learning algorithms for fraud detection and pattern analysis
- Enhanced photo verification with AI-powered evidence assessment
- Integration with existing environmental monitoring systems

### Phase 2: Ecosystem Expansion
- Partnership integrations with renewable energy providers and carbon offset programs
- Corporate sustainability program integration and bulk purchasing support
- Educational institution integration for environmental curriculum support
- Government and NGO partnership development for policy integration

### Phase 3: Global Impact Network
- International carbon credit market integration and standardization
- Cross-border environmental project coordination and funding
- Multi-language support and cultural adaptation for global deployment
- Integration with UN Sustainable Development Goals tracking and reporting

## Contributing

We welcome contributions from environmental organizations, developers, and sustainability advocates:

### Environmental Domain Expertise
- Carbon impact calculation validation and improvement
- Environmental action type definition and categorization
- Verification methodology development and quality assurance
- Scientific accuracy review and evidence-based recommendations

### Technical Development
- Smart contract optimization and feature development
- Frontend and mobile application development
- Data analytics and visualization tool development
- Integration development for external environmental data sources

### Community Building
- Beta testing with environmental organizations and community groups
- Educational content development for environmental impact awareness
- Partnership development with existing sustainability initiatives
- Community moderation and quality assurance support

## License

This project is licensed under the MIT License, promoting open-source collaboration while respecting intellectual property rights and enabling widespread adoption for environmental benefit.

## Community and Support

- **Discord**: Join environmental advocates for real-time collaboration and project coordination
- **Twitter**: Follow @EcoVaultDAO for platform updates and environmental impact stories
- **Medium**: Read detailed articles about blockchain environmental applications and case studies
- **GitHub**: Contribute to open-source development and improvement of environmental technology

---

*EcoVault: Where environmental responsibility meets blockchain innovation, creating measurable impact through community collaboration and transparent accountability.*
