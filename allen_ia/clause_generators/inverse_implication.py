from typing import List

from allen_ia.clause import Clause
from allen_ia.input.inverse_relationships_table import InverseRelationshipsTable, inverse_relationships_to_dict
from allen_ia.input.time_intervals_table import TimeIntervalsGroup
from allen_ia.literal import Literal
from allen_ia.relationship import Relationship


def generate_inverse_implication(group: TimeIntervalsGroup, table: InverseRelationshipsTable) -> List[Clause]:
    """
    Generate the clauses using the inverse implication algorithm.

    :param group: the time intervals group to execute the algorithm on.
    :param table: the inverse relationships table.
    :return: the generated clauses.
    """

    inverse_of = inverse_relationships_to_dict(table)

    # Now build the clauses.
    for intervals_relationships in group.intervals_relationships:
        for relationship in intervals_relationships.relationships:
            # Skip the equal relationship since it always generates a true value.
            if relationship == Relationship.EQUAL:
                continue

            yield [
                Literal(
                    intervals_relationships.t1,
                    intervals_relationships.t2,
                    relationship, True
                ),
                Literal(
                    intervals_relationships.t2,
                    intervals_relationships.t1,
                    inverse_of[relationship]
                )
            ]
            yield [
                Literal(
                    intervals_relationships.t2,
                    intervals_relationships.t1,
                    inverse_of[relationship], True
                ),
                Literal(
                    intervals_relationships.t1,
                    intervals_relationships.t2,
                    relationship
                )
            ]
