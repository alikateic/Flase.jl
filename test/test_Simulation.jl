using Flase, Test

world = World(
    v0=1.0,
    n_dogs=120,
    boxsize=10.0,
    motion=BrownianMotion(noise=0.5, friction=1.0),
    sheeps=DenseSheeps(10, n_sheeps=10),
)

simulation = FiniteSimulation(;
    dt=0.2,
    end_time=100.0,
    world=world,
    plotter=UnicodePlotter()
)

@testset "Move items" begin
    old_grid = copy(simulation.world.sheeps.grid)
    @test simulation.time[] < simulation.t_sheep_boredom[]
    @test Flase.move_sheep!(simulation) == false
    simulation.time[] = simulation.t_sheep_boredom[] + 1
    @test Flase.move_sheep!(simulation) == true
    simulation.time[] = zero(simulation.time[])
    @test old_grid != simulation.world.sheeps.grid
end # testset

@testset "Interactions" begin
    pos = simulation.world.dogs.member[3].position
    @test all(pos .< Flase.getSheepCoords(simulation.world, pos))
end


simulation2 = Flase.ClusterTimeSimulation(;
    condition=0,
    dt=0.2,
    world=world,
    plotter=Flase.VoidPlotter()
)

@testset "ClusterTimeSimulation" begin
    mqd = Flase.MQD()
    msd = Flase.MSD()
    mqdNorm = Flase.measure(mqd, simulation2.world.sheeps)
    @show Flase.runsim(simulation2)
    @test Flase.getMSD(msd, simulation2.world.sheeps, simulation2.world) < 0.7
    @test Flase.getMQD(mqd, simulation2.world.sheeps, mqdNorm) > 0.1
end
