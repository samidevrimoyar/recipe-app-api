"""
Views for the boat APIs.
"""
from rest_framework import viewsets
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated

from core.models import Boat
from boat import serializers


class BoatViewSet(viewsets.ModelViewSet):
    """View for manage boat APIs."""
    serializer_class = serializers.BoatSerializer
    queryset = Boat.objects.all()
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Retrieve boats for authenticated users."""
        return self.queryset.filter(user=self.request.user).order_by('-id')

    def get_serializer_class(self):
        """Return the serializer class for request."""
        if self.action == 'list':
            return serializers.BoatSerializer

        return self.serializer_class

    def perform_create(self, serializer):
        """Create a new boat."""
        serializer.save(user=self.request.user)
