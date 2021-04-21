devtools::install_github("bodkan/spammr", ref = "d6f95bf")

library(spammr)

######################################################################
# define the world map
######################################################################

world <- map(
  xrange = c(-15, 60), # min-max longitude
  yrange = c(20, 65),  # min-max latitude
  crs = "EPSG:3035"    # real projected CRS used internally
)

######################################################################
# define broader geographic regions
######################################################################

africa <- region(
  "Africa", world,
  coords = list(
    c(-18, 20), c(40, 20), c(30, 33),
    c(20, 32), c(10, 35), c(-8, 35)
  )
)

europe_anatolia <- region(
  "Western Europe & Anatolia",
  world,
  coords = list(
    c(-10, 35), c(-5, 35), c(10, 38), c(20, 35), c(38, 35),
    c(40, 40), c(30, 45), c(20, 58), c(-5, 60), c(-15, 50)
  )
)

europe <- region(
  "Western Europe",
  world,
  coords = list(
    c(-8, 35), c(-5, 36), c(10, 38), c(20, 35), c(25, 35),
    c(28, 45), c(20, 58), c(-5, 60), c(-15, 50)
  )
)

anatolia <- region(
  "Anatolia",
  world,
  coords = list(
    c(28, 35), c(40, 35),
    c(42, 40), c(30, 43), c(27, 40), c(25, 38)
  )
)

############################################
# define population dynamics
############################################

afr <- population(
  "AFR", parent = "ancestor", N = 5000,
  world = world, region = africa
)

ooa <- population(
  "OOA", parent = afr, time = 51000, N = 2000,
  center = c(33, 30), radius = 500, remove = 27000
) %>% move(
  trajectory = list(c(40, 30), c(50, 30), c(60, 40), c(70, 40)),
  start = 50000,
  end = 40000,
  snapshots = 30
)

ehg <- population(
  "EHG", time = 28000, N = 4000, parent = ooa,
  world, coords = list(
    c(26, 55), c(38, 53), c(48, 53), c(60, 53),
    c(60, 60), c(48, 63), c(38, 63), c(26, 60)
  ),
  remove = 6000
)

eur <- population(
  name = "EUR", time = 25000, N = 5000, parent = ehg,
  world, region = europe
)

ana <- population(
  name = "ANA", time = 28000, N = 8000, parent = ooa,
  world, center = c(34, 38), radius = 700,
  region = anatolia, remove = 6000
) %>% expand(
  by = 2500,
  start = 10000,
  end = 7000,
  snapshots = 10,
  region = europe_anatolia
)

yam <- population(
  name = "YAM", time = 7000, N = 6000, parent = ehg,
  world, coords = list(
    c(26, 50), c(38, 49), c(48, 50),
    c(48, 56), c(38, 59), c(26, 56)
  ),
  remove = 2000
)

yam_migr <- population(
  name = "YAM_migr", time = 6000, N = 1000, parent = yam,
  world, coords = list(
    c(26, 50), c(38, 49), c(48, 50),
    c(48, 56), c(38, 59), c(26, 56)
  ),
  remove = 2900
) %>%
  move(
    trajectory = c(15, 50),
    start = 5000,
    end = 3000,
    snapshots = 8
  )

######################################################################
# define admixture events
######################################################################

admixtures <- list(
  admixture(from = ana, to = eur, rate = 0.5, start = 8000, end = 6000),
  admixture(from = yam_migr, to = eur, rate = 0.75, start = 4000, end = 3000)
)

######################################################################
# compile the model configuration
######################################################################

model <- compile(
  populations = list(afr, ooa, ehg, eur, ana, yam, yam_migr),
  admixtures = admixtures,
  model_dir = "model-europe",
  gen_time = 30,
  resolution = 10,
  overwrite = TRUE
)

######################################################################
# plot figures to verify that the model looks reasonable
######################################################################

pdf("figures/spatial_maps.pdf", width = 13, height = 15)
plot(afr, ooa, ehg, eur, ana, yam, yam_migr, ncol = 2)
dev.off()

pdf("figures/admixture_graph.pdf", width = 13, height = 15)
graph(model)
dev.off()

######################################################################
# run the simulation
######################################################################

run(
  model, burnin = 5e6, sim_length = 55000,
  seq_length = 100e6, recomb_rate = 1e-8,
  max_interaction = 200, spread = 50,
  save_locations = TRUE,
  output_prefix = "results/europe",
  how = "dry-run", 
)
