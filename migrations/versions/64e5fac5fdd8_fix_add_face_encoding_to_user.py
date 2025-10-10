"""Fix add face_encoding to user

Revision ID: 64e5fac5fdd8
Revises: 2a925c5a1f9d
Create Date: 2025-10-01 14:04:29.893193

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '64e5fac5fdd8'
down_revision = '2a925c5a1f9d'
branch_labels = None
depends_on = None


def upgrade():
    with op.batch_alter_table('user', schema=None) as batch_op:
        batch_op.add_column(sa.Column('face_encoding', sa.LargeBinary(), nullable=True))


def downgrade():
     with op.batch_alter_table('user', schema=None) as batch_op:
        batch_op.drop_column('face_encoding')
