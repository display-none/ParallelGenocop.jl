
# MinMax to specify the type of problem
#
# use Min for minimization problems
# use Max for maximization problem
abstract MinMaxType
immutable MinType <: MinMaxType end
immutable MaxType <: MinMaxType end

const minimization = MinType()
const maximization = MaxType()



# StartPop to specify the type of the starting population
#
# use RandomStartPop for random starting population
# use SinglePointStartPop for single point starting population
abstract StartPopType
immutable RandomStartPopType <: StartPopType end
immutable SinglePointStartPopType <: StartPopType end

const random_start_pop = RandomStartPopType()
const single_point_start_pop = SinglePointStartPopType()


# defaults for GenocopSpec
const _default_population_size=70
const _default_max_iter=500
const _default_operator_frequency=Integer[4, 4, 4, 4, 4, 4, 4]
const _default_cumulative_prob_coeff=0.1
const _default_minmax_type=minimization
const _default_starting_population=random_start_pop


# constants for population initialization
const _population_initialization_tries = 100
