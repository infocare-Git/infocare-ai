import '../models/carbon_entry.dart';

/// The built-in catalog of everyday carbon-saving actions.
///
/// Factors are general per-unit averages, not a precise personal audit —
/// they're meant to make the *shape* of impact visible (which activities
/// matter most), not to stand in for a certified carbon accounting tool.
/// Sources (ranges checked September 2026):
/// - Driving-avoided factor (~0.19 kg CO2e/km): average of US EPA
///   (~0.2–0.25 kg/km for the on-road fleet) and UK DEFRA/DESNZ
///   (~0.16–0.17 kg/km) average-car figures.
/// - Public transit / carpool (~0.10 kg CO2e/km): roughly half the solo
///   driving factor, reflecting shared occupancy — a common rule of thumb,
///   not a route-specific calculation.
/// - Plant-based meal (~1.7 kg CO2e/meal) and vegetarian meal
///   (~1.0 kg CO2e/meal) vs. a meat meal: mid-range of a UK university
///   catering LCA study (Bryant Research) and food-emissions literature
///   (Our World in Data); varies a lot by what protein is being replaced.
/// - Air-dried laundry vs. machine dryer (~2.3 kg CO2e/load): typical
///   dryer energy use (~2–3 kWh/load) at an average grid emissions factor.
/// - Recycled vs. landfilled waste (~0.5 kg CO2e/kg): rough average across
///   material types from EPA WARM-style estimates.
/// - Single-use item avoided (~0.08 kg CO2e/item): conservative estimate
///   for a plastic bag/bottle/cup's production footprint.
/// - Standby power avoided (~0.05 kg CO2e/hour): typical idle-device draw
///   at an average grid emissions factor.
class CarbonCatalog {
  CarbonCatalog._();

  static const List<CarbonActivityType> activityTypes = [
    CarbonActivityType(
      id: 'biked_or_walked',
      label: 'Biked or walked instead of driving',
      icon: '🚲',
      unit: CarbonUnit.km,
      co2PerUnit: 0.19,
      sourceNote: 'vs. average car, per km (EPA/DEFRA average)',
    ),
    CarbonActivityType(
      id: 'public_transit_or_carpool',
      label: 'Took transit or carpooled instead of driving alone',
      icon: '🚌',
      unit: CarbonUnit.km,
      co2PerUnit: 0.10,
      sourceNote: 'vs. driving alone, per km (shared-occupancy estimate)',
    ),
    CarbonActivityType(
      id: 'plant_based_meal',
      label: 'Ate a plant-based meal instead of meat',
      icon: '🥗',
      unit: CarbonUnit.meal,
      co2PerUnit: 1.7,
      sourceNote: 'vs. a meat meal, per meal (food LCA estimate)',
    ),
    CarbonActivityType(
      id: 'vegetarian_meal',
      label: 'Ate a vegetarian meal instead of meat',
      icon: '🍲',
      unit: CarbonUnit.meal,
      co2PerUnit: 1.0,
      sourceNote: 'vs. a meat meal, per meal (food LCA estimate)',
    ),
    CarbonActivityType(
      id: 'air_dried_laundry',
      label: 'Air-dried laundry instead of using a dryer',
      icon: '🧺',
      unit: CarbonUnit.load,
      co2PerUnit: 2.3,
      sourceNote: 'per load (typical dryer energy use)',
    ),
    CarbonActivityType(
      id: 'recycled_waste',
      label: 'Recycled instead of binning',
      icon: '♻️',
      unit: CarbonUnit.kgWaste,
      co2PerUnit: 0.5,
      sourceNote: 'per kg recycled (average across materials)',
    ),
    CarbonActivityType(
      id: 'avoided_single_use',
      label: 'Skipped a single-use bag, bottle, or cup',
      icon: '🚯',
      unit: CarbonUnit.item,
      co2PerUnit: 0.08,
      sourceNote: 'per item avoided',
    ),
    CarbonActivityType(
      id: 'unplugged_standby',
      label: 'Unplugged or switched off idle devices',
      icon: '🔌',
      unit: CarbonUnit.hour,
      co2PerUnit: 0.05,
      sourceNote: 'per hour of standby power avoided',
    ),
  ];

  static CarbonActivityType? byId(String id) {
    for (final t in activityTypes) {
      if (t.id == id) return t;
    }
    return null;
  }
}
