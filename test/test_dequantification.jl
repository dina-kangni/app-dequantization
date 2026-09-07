# test_dequantification.jl
# teste toutes les fonctions de dequantification.jl

using Test
include("../src/algorithme/dequantification.jl")

# ------ est_compatible ------
@testset "est_compatible" begin
    P = Dict{Tuple{Int16,Int16},Int}((Int16(2), Int16(3)) => 1, (Int16(2), Int16(4)) => 0)

    # ordre des champs : (valeur, parent, pos, enfants, histogramme, vivant)
    noeud = Noeud(Int16(2), nothing, false, Noeud[], P, true)

    @test est_compatible(noeud, Int16(3)) == true
    @test est_compatible(noeud, Int16(4)) == false
    @test est_compatible(noeud, Int16(99)) == false

    # si histogramme est nothing -> false (pas de crash)
    noeud_mort = Noeud(Int16(2), nothing, false, Noeud[], nothing, false)
    @test est_compatible(noeud_mort, Int16(3)) == false
end

# ------ sauvegarder_solution ------
@testset "sauvegarder_solution" begin
    dossier_temp = joinpath(@__DIR__, "data", "temp")
    mkpath(dossier_temp)

    solution = Int16[2, 3, 4, 5]
    compteur = Ref{Int}(0)

    chemin = sauvegarder_solution(solution, dossier_temp, compteur)
    @test compteur[] == 1
    @test isfile(chemin)
    @test endswith(chemin, "solution_1.dat")

    chemin2 = sauvegarder_solution(solution, dossier_temp, compteur)
    @test compteur[] == 2
    @test endswith(chemin2, "solution_2.dat")

    rm(chemin, force=true)
    rm(chemin2, force=true)
end

# ------ elaguer! ------
@testset "elaguer! marque vivant=false" begin
    arbre = creer_arbre()
    P = Dict{Tuple{Int16,Int16},Int}((Int16(0), Int16(2)) => 1, (Int16(2), Int16(4)) => 1)
    e1 = ajouter_enfant!(arbre, arbre.racine, Int16(2), false, P)
    e2 = ajouter_enfant!(arbre, e1, Int16(4), false, P)

    elaguer!(arbre, e2)

    @test e2.vivant == false
    @test e1.vivant == false
    @test length(e1.enfants) == 1      # toujours la physiquement
    @test compter_branches(arbre.racine) == 0
end

@testset "elaguer! garde le frere vivant" begin
    arbre = creer_arbre()
    P = Dict{Tuple{Int16,Int16},Int}(
        (Int16(0), Int16(2)) => 1,
        (Int16(2), Int16(4)) => 1,
        (Int16(2), Int16(5)) => 1
    )
    e1 = ajouter_enfant!(arbre, arbre.racine, Int16(2), false, P)
    e2 = ajouter_enfant!(arbre, e1, Int16(4), false, P)
    e3 = ajouter_enfant!(arbre, e1, Int16(5), true, P)

    elaguer!(arbre, e2)

    @test e2.vivant == false
    @test e1.vivant == true
    @test e3.vivant == true
    @test compter_branches(arbre.racine) == 1
end

# ------ dequantifier ------
@testset "dequantifier cas simple" begin
    xQ = Int16[2, 2]
    P = Dict{Tuple{Int16,Int16},Int}(
        (Int16(2), Int16(2)) => 0,
        (Int16(2), Int16(3)) => 1
    )

    solutions_trouvees = String[]
    fonction_arbre(a) = nothing
    fonction_branches(n) = nothing
    fonction_solution(chemin) = push!(solutions_trouvees, chemin)

    dossier_temp = joinpath(@__DIR__, "data", "temp")
    mkpath(dossier_temp)
    est_lance = Ref{Bool}(true)

    dequantifier(xQ, P, fonction_arbre, fonction_branches, fonction_solution, dossier_temp, est_lance)

    @test length(solutions_trouvees) >= 1
    for chemin in solutions_trouvees
        rm(chemin, force=true)
    end
end

@testset "dequantifier aucune solution" begin
    xQ = Int16[2, 2]
    P = Dict{Tuple{Int16,Int16},Int}()

    solutions_trouvees = String[]
    fonction_arbre(a) = nothing
    fonction_branches(n) = nothing
    fonction_solution(chemin) = push!(solutions_trouvees, chemin)

    dossier_temp = joinpath(@__DIR__, "data", "temp")
    mkpath(dossier_temp)
    est_lance = Ref{Bool}(true)

    dequantifier(xQ, P, fonction_arbre, fonction_branches, fonction_solution, dossier_temp, est_lance)

    @test length(solutions_trouvees) == 0
end