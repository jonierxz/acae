"""Add face_encoding column

Revision ID: 2a925c5a1f9d
Revises: 5ebab34b08a5
Create Date: 2025-10-01 13:55:05.690070

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '2a925c5a1f9d'
down_revision = '5ebab34b08a5'
branch_labels = None
depends_on = None


def upgrade():
    # ✅ agrega la columna en la tabla user
    op.add_column('user', sa.Column('face_encoding', sa.LargeBinary(), nullable=True))


def downgrade():
    # ✅ elimina la columna en caso de rollback
    op.drop_column('user', 'face_encoding')
